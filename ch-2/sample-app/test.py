import unittest
from app import hello

class TestHelloApp(unittest.TestCase):

  def test_hello(self):
    self.assertEqual(hello(), "AC Challenge V1\n")

if __name__ == '__main__':
  unittest.main()