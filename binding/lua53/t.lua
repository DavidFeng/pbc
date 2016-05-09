#!/usr/bin/env lua53
local print = print

local protobuf = require "protobuf"

local inspect = require 'inspect'


protobuf.register_file('test.pb')


local msg_type = 'Test.B'
local msg = {b4 = {}}

local b = protobuf.decode(msg_type, protobuf.encode(msg_type, msg))
print('decode: ', inspect(b.b4))

b = protobuf.decode_ex(msg_type, protobuf.encode(msg_type, msg))
print(inspect(b))
