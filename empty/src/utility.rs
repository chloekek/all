pub use utility::Direction::*;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Point
{
    pub x: i32,
    pub y: i32,
}

impl Point
{
    pub fn in_direction(self, dir: Direction) -> Point
    {
        match dir {
            North     => Point{x: self.x    , y: self.y + 1},
            Northeast => Point{x: self.x + 1, y: self.y + 1},
            East      => Point{x: self.x + 1, y: self.y    },
            Southeast => Point{x: self.x + 1, y: self.y - 1},
            South     => Point{x: self.x    , y: self.y - 1},
            Southwest => Point{x: self.x - 1, y: self.y - 1},
            West      => Point{x: self.x - 1, y: self.y    },
            Northwest => Point{x: self.x - 1, y: self.y + 1},
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Direction
{
    North,
    Northeast,
    East,
    Southeast,
    South,
    Southwest,
    West,
    Northwest,
}
