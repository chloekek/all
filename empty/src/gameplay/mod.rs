pub mod map;
pub mod port;

use gameplay::map::Tile;
use gameplay::port::Port;
use utility::Direction;
use utility::Point;

/// A gameplay object keeps track of all the state of the game objects.
#[derive(Clone, Debug)]
pub struct Gameplay
{
    pub port: Port,
}

/// The methods in this impl directly manipulate the game world.
/// These methods do not implement entire game rules,
/// but can be used to implement game rules.
impl Gameplay
{
    /// Get the tile at the specified position.
    pub fn frob_tile_at(&self, _pos: Point) -> Tile
    {
        Tile::Grass
    }
}

/// The methods in this impl correspond to
/// actions that the player can directly perform.
/// As such, these methods apply
/// all the complicated game rules, status effects, etc.
/// These methods should not be considered simple, low-level primitives.
impl Gameplay
{
    /// Walk Port in the specified direction.
    pub fn act_walk(&mut self, dir: Direction) -> ActWalkResult
    {
        let new_position = self.port.position.in_direction(dir);
        match self.frob_tile_at(new_position) {
            Tile::Grass | Tile::Mud => {
                self.port.position = new_position;
                ActWalkResult::Success
            },
            Tile::Rock => ActWalkResult::ObstructedByRock,
        }
    }
}

/// Return type of [Gameplay::act_walk].
#[derive(Clone, Copy, Debug)]
pub enum ActWalkResult
{
    Success,
    ObstructedByRock,
}
