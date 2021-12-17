#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy, Default)]
pub struct Plane {
    min_x: i32,
    min_y: i32,
    max_x: i32,
    max_y: i32,
}

impl Plane {
    pub fn new(min_x: i32, min_y: i32, max_x: i32, max_y: i32) -> Self {
        Plane {
            min_x,
            min_y,
            max_x,
            max_y,
        }
    }

    /// Get a reference to the plane's min x.
    pub fn min_x(&self) -> i32 {
        self.min_x
    }

    /// Get a reference to the plane's min y.
    pub fn min_y(&self) -> i32 {
        self.min_y
    }

    /// Get a reference to the plane's max x.
    pub fn max_x(&self) -> i32 {
        self.max_x
    }

    /// Get a reference to the plane's max y.
    pub fn max_y(&self) -> i32 {
        self.max_y
    }
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy, Default)]
pub struct Point {
    x: i32,
    y: i32,
}

#[allow(dead_code)]
impl Point {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    pub fn x(&self) -> i32 {
        self.x
    }

    pub fn y(&self) -> i32 {
        self.y
    }

    pub fn is_on_plane(&self, p: &Plane) -> bool {
        self.x >= p.min_x && self.x <= p.max_x && self.y >= p.min_y && self.y <= p.max_y
    }

    pub fn cross_adj(&self) -> impl Iterator<Item = Point> {
        vec![
            Point {
                x: self.x - 1,
                y: self.y,
            },
            Point {
                x: self.x + 1,
                y: self.y,
            },
            Point {
                x: self.x,
                y: self.y - 1,
            },
            Point {
                x: self.x,
                y: self.y + 1,
            },
        ]
        .into_iter()
    }

    pub fn diagonal_adj(&self) -> impl Iterator<Item = Point> {
        vec![
            Point {
                x: self.x - 1,
                y: self.y - 1,
            },
            Point {
                x: self.x + 1,
                y: self.y - 1,
            },
            Point {
                x: self.x - 1,
                y: self.y + 1,
            },
            Point {
                x: self.x + 1,
                y: self.y + 1,
            },
        ]
        .into_iter()
    }

    pub fn arround_adj(&self) -> impl Iterator<Item = Point> {
        self.cross_adj().chain(self.diagonal_adj())
    }

    pub fn moving(&mut self, dx: i32, dy: i32) -> () {
        self.x += dx;
        self.y += dy;
    }
}
