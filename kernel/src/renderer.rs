#![allow(dead_code)]

use bootloader_api::info::{FrameBufferInfo, PixelFormat};
use font::RasterizedChar;
use noto_sans_mono_bitmap as font;

use core::ptr;

mod style {
    //! Constants that define the style of how fonts are rendered
    use super::{
        font,
        font::{FontWeight, RasterHeight},
    };

    /// Weight (thickness) of each character raster.
    pub const WEIGHT: FontWeight = FontWeight::Regular;

    /// Height of each character raster.
    pub const HEIGHT: RasterHeight = RasterHeight::Size16;

    /// Width of each character raster. Guaranteed to be the same since its a
    /// mono font
    pub const WIDTH: usize = font::get_raster_width(WEIGHT, HEIGHT);

    /// The space between each line of text
    pub const LINE_SPACING: usize = 2;

    /// The space between each character on a line
    pub const LETTER_SPACING: usize = 0;

    /// Padding from the border of the framebuffer
    pub const PADDING: usize = 1;

    /// Default character when one if symbol is not provided by [`font`]
    pub const DEFAULT_CHAR: char = '�';
}

/// Get the raster of a character from [`font`]
fn get_raster(c: char) -> font::RasterizedChar {
    fn rasterise(c: char) -> Option<font::RasterizedChar> {
        font::get_raster(c, style::WEIGHT, style::HEIGHT)
    }

    rasterise(c).unwrap_or_else(|| {
        rasterise(style::DEFAULT_CHAR).expect("should have rasterised default char")
    })
}

/// Renders text to the screen using the [`FrameBuffer`] provided by the bootloader.
///
/// [`FrameBuffer`]: bootloader_api::info::FrameBuffer
pub struct Renderer {
    framebuffer: &'static mut [u8],
    info: FrameBufferInfo,
    x: usize,
    y: usize,
}

impl Renderer {
    /// Create a new renderer
    pub fn new(framebuffer: &'static mut [u8], info: FrameBufferInfo) -> Self {
        Self {
            framebuffer,
            info,
            x: 0,
            y: 0,
        }
    }

    /// Writes a character to the framebuffer while handling special control
    /// characters
    fn write_char(&mut self, c: char) {
        match c {
            '\n' => self.newline(), // carriage returns will **not** be supported
            c => {
                let new_x = self.x + style::WIDTH;
                if new_x > self.frame_width() {
                    self.newline();
                }

                let new_y = self.y + style::HEIGHT.val() + style::PADDING;
                if new_y > self.frame_height() {
                    self.clear();
                }
                self.write_rendered_character(get_raster(c));
            }
        }
    }

    /// Prints a rendered character onto the framebuffer; byte by byte, pixel by
    /// pixel
    fn write_rendered_character(&mut self, rendered_char: RasterizedChar) {
        for (y, row) in rendered_char.raster().iter().enumerate() {
            for (x, byte) in row.iter().enumerate() {
                self.write_pixel(self.x + x, self.x + y, *byte);
            }
        }
        // replace with rendered_char.width() if broken
        self.x += style::WIDTH + style::LETTER_SPACING;
    }

    /// Writes a singular pixel to the frambuffer. One pixel is represented by
    /// one byte for clarity of raster
    fn write_pixel(&mut self, x: usize, y: usize, intensity: u8) {
        let pixel_offset = y * self.info.stride + x;
        let color = match self.info.pixel_format {
            PixelFormat::Rgb => [intensity, intensity, intensity / 2, 0],
            PixelFormat::Bgr => [intensity / 2, intensity, intensity, 0],
            PixelFormat::U8 => [if intensity > 200 { 0xf } else { 0 }, 0, 0, 0],
            other => {
                // set a supported (but invalid) pixel format before panicking to avoid a double
                // panic; it might not be readable though
                self.info.pixel_format = PixelFormat::Rgb;
                panic!("pixel format {:?} not supported in logger", other)
            }
        };
        let bytes_per_pixel = self.info.bytes_per_pixel;
        let byte_offset = pixel_offset * bytes_per_pixel;

        self.framebuffer[byte_offset..(byte_offset + bytes_per_pixel)]
            .copy_from_slice(&color[..bytes_per_pixel]);
        unsafe { ptr::read_volatile(&self.framebuffer[byte_offset]) };
    }

    /// Erases the framebuffer
    pub fn clear(&mut self) {
        (self.x, self.y) = (style::PADDING, style::PADDING);
        self.framebuffer.fill(0);
    }

    /// Insert a new line by moving y down and x back
    fn newline(&mut self) {
        self.y += style::HEIGHT.val() + style::LINE_SPACING;
        self.x = style::PADDING;
    }

    /// Returns the width of the framebuffer in pixel
    fn frame_width(&self) -> usize {
        self.info.width
    }

    /// Returns the height of the framebuffer in pixel
    fn frame_height(&self) -> usize {
        self.info.height
    }
}
