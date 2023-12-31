"""
Test custom Django management commands.
"""
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """ Test commands. """

    def test_wait_for_db_ready(self, patched_check):
        """ Test waiting for db if db ready. """
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    # WE USE SLEEP TO DELAY THE TRIES WHEN WE WANT TO CONNECT TO OUR DB
    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """ Test waiting for db when getting OperationalError """
        """ THE SIDE EFFECT METHOD ACCEPTS A LIST OF VALUES LIKE EXCEPTIONS
            OR BOOLEANS, AND WE ARE SAYING IN THE MOCK THAT
            WE WAIT 2 PYSCOPG2 ERRORS THEN 3 OPERATIONAL ERRORS AND
            IN THE SIXTH CALL WE WIL HAVE A TRUE VALUE"""
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
