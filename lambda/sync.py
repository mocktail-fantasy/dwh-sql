#!/usr/bin/python
import datetime
import gzip
import os
import sys
from dataclasses import dataclass
from io import BytesIO
from typing import Callable, Optional

from repositories.file_repo import DataFileRepo

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")


@dataclass
class DatasetSpec:
    dataset: str
    fetch: Callable
    start_year: Optional[int]  # None = single static file, no year in path
    gzipped: bool = False
    use_off_season: bool = False  # use off_season_year instead of in_season_year on update


class DataSync:
    def __init__(self, output_dir: str = DATA_DIR):
        self.output_dir = output_dir
        self.file_repo = DataFileRepo()
        self.in_season_year = nfl_in_season_year_for_today()
        self.off_season_year = nfl_off_season_year_for_today()
        fr = self.file_repo
        self.specs = [
            DatasetSpec("play_by_play",                    fr.get_play_by_play,   1999),
            DatasetSpec("players",                         fr.get_players,        None),
            DatasetSpec("weekly",                          fr.get_weekly,         1999),
            DatasetSpec("combine",                         fr.get_combine,        None),
            DatasetSpec("rushing_next_gen_stats",          fr.get_ngs_rushing,    2016, gzipped=True),
            DatasetSpec("passing_next_gen_stats",          fr.get_ngs_passing,    2016, gzipped=True),
            DatasetSpec("receiving_next_gen_stats",        fr.get_ngs_receiving,  2016, gzipped=True),
            DatasetSpec("depth_charts",                    fr.get_depth_charts,   2001),
            DatasetSpec("rushing_pro_football_reference",  fr.get_pfr_rushing,    2018),
            DatasetSpec("passing_pro_football_reference",  fr.get_pfr_passing,    2018),
            DatasetSpec("receiving_pro_football_reference",fr.get_pfr_receiving,  2018),
            DatasetSpec("snaps",                           fr.get_snaps,          2012),
            DatasetSpec("ftn",                             fr.get_ftn,            2022),
            DatasetSpec("rosters",                         fr.get_weekly_rosters, 2002, use_off_season=True),
            DatasetSpec("odds",                            fr.get_game_odds,      None),
            DatasetSpec("player_ids",                      fr.get_player_ids,     None),
        ]

    def _fetch(self, spec: DatasetSpec, year: Optional[int] = None) -> bytes:
        data = spec.fetch(year) if year is not None else spec.fetch()
        if spec.gzipped:
            with BytesIO(data) as buf:
                with gzip.GzipFile(fileobj=buf, mode="rb") as f:
                    data = f.read()
        return data

    def _write_local(self, key: str, body: bytes):
        # To switch back to S3: replace this method body with:
        #   self.s3.put_object(Bucket=self.s3_bucket, Key=key, Body=body)
        file_path = os.path.join(self.output_dir, key)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "wb") as f:
            f.write(body)
        print(f"Wrote {file_path}")

    def _sync(self, spec: DatasetSpec, year: Optional[int] = None):
        key = f"{spec.dataset}/{spec.dataset}.csv" if year is None else f"{spec.dataset}/{year}.csv"
        print(f"Fetching {spec.dataset}" + (f" ({year})" if year else ""))
        self._write_local(key, self._fetch(spec, year))

    def initialize(self):
        print("initializing data..")
        for spec in self.specs:
            if spec.start_year is None:
                self._sync(spec)
            else:
                for year in range(spec.start_year, self.in_season_year + 1):
                    self._sync(spec, year)

    def update(self):
        print("updating data..")
        for spec in self.specs:
            if spec.start_year is None:
                self._sync(spec)
            else:
                year = self.off_season_year if spec.use_off_season else self.in_season_year
                self._sync(spec, year)


def nfl_in_season_year_for_today():
    """Return the NFL season year based on today's date.
    If today's date is on or after this year's first Sunday of the NFL season,
    return this year. Otherwise, return the previous year.
    """
    today = datetime.date.today()
    year = today.year

    sept_first = datetime.date(year, 9, 1)
    first_monday_offset = (0 - sept_first.weekday()) % 7
    labor_day = sept_first + datetime.timedelta(days=first_monday_offset)
    first_nfl_sunday = labor_day + datetime.timedelta(days=6)

    if today >= first_nfl_sunday:
        return year
    else:
        return year - 1


def nfl_off_season_year_for_today():
    """Return the NFL season year based on today's date.
    If today's date is on or after this year's NFL offseason start (new league year),
    return this year. Otherwise, return the previous year.
    """
    today = datetime.date.today()
    year = today.year

    offseason_start = datetime.date(year, 3, 12)

    if today >= offseason_start:
        return year
    else:
        return year - 1


if __name__ == "__main__":
    sync = DataSync()
    mode = sys.argv[1] if len(sys.argv) > 1 else "update"
    if mode == "initialize":
        sync.initialize()
    else:
        sync.update()
