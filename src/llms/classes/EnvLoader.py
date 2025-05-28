import os
from os.path import join

from dotenv import load_dotenv

from .DebugLogger import DebugLogger


class EnvLoader:
    def __init__(self, env_dir: str = "env"):
        """
        Initialize the EnvLoader class with the directory where the .env files are located.

        :param env_dir: The directory containing the .env files.
        """
        self.env_dir = env_dir
        self.logger = DebugLogger()

    def load_env_files(self):
        """
        Loads all .env files from the specified directory into the environment variables.
        """
        if not os.path.exists(self.env_dir):
            print(self.env_dir)
            raise FileNotFoundError(f"The directory {self.env_dir} does not exist.")

        for filename in os.listdir(self.env_dir):
            path_to_env = join(self.env_dir, filename)
            if path_to_env.endswith(".env"):
                self.logger.info(f"Loading {path_to_env}...")
                load_dotenv(path_to_env)
