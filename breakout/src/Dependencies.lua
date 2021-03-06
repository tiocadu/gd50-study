-- importing constants
require 'src/constants'

-- instead of using a package manager, i'm going with local dependences
-- https://github.com/Ulydev/push/blob/master/push.lua
push = require 'libs/push'

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'libs/class'

-- import our sprites and quads
require 'src/Util'

-- objects
require 'src/Paddle'
require 'src/Ball'
require 'src/Brick'

-- level generator
require 'src/LevelMaker'

-- states
require 'src/StateMachine'
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PaddleSelectionState'
require 'src/states/ServeState'
require 'src/states/PlayState'
require 'src/states/GameOverState'
require 'src/states/NewHighScoreState'
require 'src/states/HighScoreState'
