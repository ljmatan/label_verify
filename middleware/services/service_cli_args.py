import argparse


class ServiceCliArgs:
    """
    Command Line Interface argument handling service.
    """

    @classmethod
    def get_args(cls) -> argparse.Namespace:
        """
        Method used for fetching the object holding the CLI argument attributes.
        """

        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--ppid",
            type=int,
            default=-1,
            help="Parent process ID.",
        )
        parser.add_argument(
            "--port",
            type=int,
            required=True,
            help="Server port number.",
        )
        args = parser.parse_args()
        return args
