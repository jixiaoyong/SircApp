import unittest
from PIL import Image
from run import compose


class CompositionTest(unittest.TestCase):
    def test_complementary_geometry(self):
        left = Image.new('RGB', (1440, 1000), 'white')
        right = Image.new('RGB', left.size, 'black')
        for reverse, top, bottom in [(False, 960, 480), (True, 480, 960)]:
            image = compose(left, right, reverse)
            for y, boundary in [(0, top), (999, bottom)]:
                self.assertEqual(image.getpixel((boundary - 1, y)), (255, 255, 255))
                self.assertEqual(image.getpixel((boundary + 1, y)), (0, 0, 0))
            self.assertEqual(image.getpixel((700, 500)), (255, 255, 255))
            self.assertEqual(image.getpixel((740, 500)), (0, 0, 0))

    def test_dimension_mismatch_fails(self):
        with self.assertRaises(AssertionError):
            compose(Image.new('RGB', (2, 2)), Image.new('RGB', (3, 2)))


if __name__ == '__main__':
    unittest.main()
