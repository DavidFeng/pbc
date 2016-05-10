#!/usr/bin/env lua53
local print = print

local protobuf = require "protobuf"

local inspect = require 'inspect'


protobuf.register_file('test.pb')


local msg_type = 'Test.B'
local msg = {
  b4 = {
    { a1 = 1, },
    { a1 = 2, },
  },
  b5 = {
    {
      c1 = {
        { a1 = 3 },
        { a1 = 4 },
        { },
        { },
      },
      c2 = {
        true, false, true,
      },
    },
  },
  b6 = {
    {},
    { bc1 = {}, bc4 = {}, bc3 = {{}}},
    { bc1 = { a1 = 5, a2 = 2 }, bc2 = {{}, {}}},

    {
      bc1 = { a1 = 5, a2 = 2 },
      bc2 = {
        {bb1 = 999,},
        {bb2 = 998,},
      },
      bc4 = {
        true, false
      },

    },
  },
}

local b
b = protobuf.decode_ex(msg_type, protobuf.encode(msg_type, msg))
print(inspect(b))
