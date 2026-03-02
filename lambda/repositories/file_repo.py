import http.client
import ssl
from urllib.parse import urlparse

NFLVERSE_HOST = "github.com"
NFLVERSE_BASE = "/nflverse/nflverse-data/releases/download"


class DataFileRepo:

    def get_play_by_play(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/pbp/play_by_play_{year}.csv")

    def get_players(self):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/players/players.csv")

    def get_weekly(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/stats_player/stats_player_week_{year}.csv")

    def get_combine(self):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/combine/combine.csv")

    def get_ngs_rushing(self):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/nextgen_stats/ngs_rushing.csv.gz")

    def get_ngs_passing(self):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/nextgen_stats/ngs_passing.csv.gz")

    def get_ngs_receiving(self):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/nextgen_stats/ngs_receiving.csv.gz")

    def get_pfr_rushing(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/pfr_advstats/advstats_week_rush_{year}.csv")

    def get_pfr_passing(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/pfr_advstats/advstats_week_pass_{year}.csv")

    def get_pfr_receiving(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/pfr_advstats/advstats_week_rec_{year}.csv")

    def get_snaps(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/snap_counts/snap_counts_{year}.csv")

    def get_ftn(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/ftn_charting/ftn_charting_{year}.csv")

    def get_weekly_rosters(self, year):
        return self._get_file(NFLVERSE_HOST, f"{NFLVERSE_BASE}/weekly_rosters/roster_weekly_{year}.csv")

    def get_game_odds(self):
        return self._get_file("nflgamedata.com", "/games.csv")

    def get_player_ids(self):
        return self._get_file("raw.githubusercontent.com", "/dynastyprocess/data/master/files/db_playerids.csv")

    def _get_file(self, hostname, path, max_redirects=5):
        print(f"Requesting data for host: {hostname} path: {path}")

        if max_redirects <= 0:
            raise Exception("Too many redirects")

        conn = http.client.HTTPSConnection(hostname, context=ssl.create_default_context())
        conn.request("GET", path)
        response = conn.getresponse()
        print("Status:", response.status, response.reason)

        if response.status == 200:
            data = response.read()
            conn.close()
            return data

        elif response.status == 302:
            new_location = response.getheader("Location")
            print(f"Redirecting to {new_location}")
            conn.close()
            new_url = urlparse(new_location)
            new_path = new_url.path + (f"?{new_url.query}" if new_url.query else "")
            return self._get_file(new_url.netloc, new_path, max_redirects - 1)

        else:
            conn.close()
            raise Exception(f"Request failed with status: {response.status}, {response.reason}")
