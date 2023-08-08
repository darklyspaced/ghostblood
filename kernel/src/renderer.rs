use bootloader_api::info::FrameBufferInfo;
use noto_sans_mono_bitmap as font;

/// Padding from the border for the renderer
const PADDING: u8 = 1;

mod fstyle {
    //! Constants that define the style of the font itself
    use super::{
        font,
        font::{FontWeight, RasterHeight},
    };

    /// Weight (thickness) of each character raster.
    pub const WEIGHT: FontWeight = FontWeight::Regular;

    /// Height of each character raster.
    pub const HEIGHT: RasterHeight = RasterHeight::Size16;

    /// Width of each character raster.
    pub const WIDTH: usize = font::get_raster_width(WEIGHT, HEIGHT);

    /// Default character when one if symbol is not provided by [`font`]
    pub const DEFAULT_CHAR: char = '�';
}

struct Renderer {
    framebuffer: &'static mut [u8],
    info: FrameBufferInfo,
    x: usize,
    y: usize,
}

impl Renderer {
    pub fn new(framebuffer: &'static mut [u8], info: FrameBufferInfo) -> Self {
        Self {
            framebuffer,
            info,
            x: 0,
            y: 0,
        }
    }

    fn get_raster(c: char) -> font::RasterizedChar {
        fn rasterise(c: char) -> Option<font::RasterizedChar> {
            font::get_raster(c, fstyle::WEIGHT, fstyle::HEIGHT)
        }

        rasterise(c).unwrap_or_else(|| {
            rasterise(fstyle::DEFAULT_CHAR).expect("should have rasterised default char")
        })
    }
}
