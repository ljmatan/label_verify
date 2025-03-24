import psutil
import time
import os
import threading


class ServiceProcess:
    """
    Class dedicated to handling the server runtime process.
    """

    @classmethod
    def is_parent_running(cls, parent_pid):
        """
        Verifies if the parent process is running using the psutil library.
        """

        try:
            parent_process = psutil.Process(parent_pid)
            return parent_process.is_running()
        except psutil.NoSuchProcess:
            return False

    @classmethod
    def monitor_parent(cls, parent_pid):
        """
        Monitors the process with the specified ID on order to determine whether it's still running.
        """

        while cls.is_parent_running(parent_pid):
            time.sleep(1)
        print("Parent process is no longer running. Exiting Flask server.")
        os._exit(0)

    @classmethod
    def start_monitoring(cls, parent_pid):
        """
        Start monitoring the parent process in a separate thread.
        """

        monitor_thread = threading.Thread(target=cls.monitor_parent, args=(parent_pid,))
        monitor_thread.daemon = (
            True  # Allow the thread to exit when the main program exits
        )
        monitor_thread.start()
