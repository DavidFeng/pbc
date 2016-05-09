#!/usr/bin/env lua53
local print = print

local protobuf = require "protobuf"

local inspect = require 'inspect'


protobuf.register_file('test.pb')


local msg_type = 'Test.B'

local b = protobuf.decode(msg_type, protobuf.encode(msg_type, {}))
print(inspect(b))

local b = protobuf.decode_ex(msg_type, protobuf.encode(msg_type, {}))
print(inspect(b))
