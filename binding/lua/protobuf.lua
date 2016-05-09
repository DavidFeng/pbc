local c = require "protobuf.c"

local setmetatable = setmetatable
local type = type
local table = table
local assert = assert
local pairs = pairs
local ipairs = ipairs
local string = string
local print = print
local io = io
local tinsert = table.insert
local rawget = rawget
local getmetatable = getmetatable
local next = next

module "protobuf"

local _pattern_cache = {}

-- skynet clear
local P = c._env_new()
local GC = c._gc(P)

function lasterror()
  return c._last_error(P)
end

local decode_type_cache = {}

local _R_meta = {
  __index = function (self, key)
    local v = decode_type_cache[self._CType][key](self, key)
    self[key] = v
    return v
  end,
}

local _reader = {}

function _reader:int(key)
  return c._rmessage_integer(self._CObj , key , 0)
end

function _reader:real(key)
  return c._rmessage_real(self._CObj , key , 0)
end

function _reader:string(key)
  return c._rmessage_string(self._CObj , key , 0)
end

function _reader:bool(key)
  return c._rmessage_integer(self._CObj , key , 0) ~= 0
end

function _reader:message(key, message_type)
  local rmessage = c._rmessage_message(self._CObj , key , 0)
  if rmessage then
    local v = {
      _CObj = rmessage,
      _CType = message_type,
      _Parent = self,
    }
    return setmetatable( v , _R_meta )
  end
end

function _reader:int32(key)
  return c._rmessage_int32(self._CObj , key , 0)
end

function _reader:int64(key)
  return c._rmessage_int64(self._CObj , key , 0)
end

function _reader:int52(key)
  return c._rmessage_int52(self._CObj , key , 0)
end

function _reader:uint52(key)
  return c._rmessage_uint52(self._CObj , key , 0)
end

function _reader:int_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_integer(cobj , key , i))
  end
  return ret
end

function _reader:real_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_real(cobj , key , i))
  end
  return ret
end

function _reader:string_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_string(cobj , key , i))
  end
  return ret
end

function _reader:bool_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_integer(cobj , key , i) ~= 0)
  end
  return ret
end

function _reader:message_repeated(key, message_type)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    local m = {
      _CObj = c._rmessage_message(cobj , key , i),
      _CType = message_type,
      _Parent = self,
    }
    tinsert(ret, setmetatable( m , _R_meta ))
  end
  return ret
end

function _reader:int32_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_int32(cobj , key , i))
  end
  return ret
end

function _reader:int64_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_int64(cobj , key , i))
  end
  return ret
end

function _reader:int52_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_int52(cobj , key , i))
  end
  return ret
end

function _reader:uint52_repeated(key)
  local cobj = self._CObj
  local n = c._rmessage_size(cobj , key)
  local ret = {}
  for i=0,n-1 do
    tinsert(ret,  c._rmessage_uint52(cobj , key , i))
  end
  return ret
end

_reader[1] = function(msg) return _reader.int end
_reader[2] = function(msg) return _reader.real end
_reader[3] = function(msg) return _reader.bool end
_reader[4] = function(msg) return _reader.string end
_reader[5] = function(msg) return _reader.string end
_reader[6] = function(msg)
  local message = _reader.message
  return  function(self,key)
      return message(self, key, msg)
    end
end
_reader[7] = function(msg) return _reader.int64 end
_reader[8] = function(msg) return _reader.int32 end
_reader[9] = _reader[5]
_reader[10] = function(msg) return _reader.int52 end
_reader[11] = function(msg) return _reader.uint52 end

_reader[128+1] = function(msg) return _reader.int_repeated end
_reader[128+2] = function(msg) return _reader.real_repeated end
_reader[128+3] = function(msg) return _reader.bool_repeated end
_reader[128+4] = function(msg) return _reader.string_repeated end
_reader[128+5] = function(msg) return _reader.string_repeated end
_reader[128+6] = function(msg)
  local message = _reader.message_repeated
  return  function(self,key)
      return message(self, key, msg)
    end
end
_reader[128+7] = function(msg) return _reader.int64_repeated end
_reader[128+8] = function(msg) return _reader.int32_repeated end
_reader[128+9] = _reader[128+5]
_reader[128+10] = function(msg) return _reader.int52_repeated end
_reader[128+11] = function(msg) return _reader.uint52_repeated end

local _decode_type_meta = {}

function _decode_type_meta:__index(key)
  local t, msg = c._env_type(P, self._CType, key)
  local func = assert(_reader[t],key)(msg)
  self[key] = func
  return func
end

setmetatable(decode_type_cache , {
  __index = function(self, key)
    local v = setmetatable({ _CType = key } , _decode_type_meta)
    self[key] = v
    return v
  end
})

local function decode_message( message , buffer, length)
  local rmessage = c._rmessage_new(P, message, buffer, length)
  if rmessage then
    local self = {
      _CObj = rmessage,
      _CType = message,
    }
    c._add_rmessage(GC,rmessage)
    return setmetatable( self , _R_meta )
  end
end

----------- encode ----------------

local encode_type_cache = {}

local function encode_message(CObj, message_type, t)
  local type = encode_type_cache[message_type]
  for k,v in pairs(t) do
    local func = type[k]
    func(CObj, k , v)
  end
end

local _writer = {
  int = c._wmessage_integer,
  real = c._wmessage_real,
  enum = c._wmessage_string,
  string = c._wmessage_string,
  int64 = c._wmessage_int64,
  int32 = c._wmessage_int32,
  int52 = c._wmessage_int52,
  uint52 = c._wmessage_uint52,
}

function _writer:bool(k,v)
  c._wmessage_integer(self, k, v and 1 or 0)
end

function _writer:message(k, v , message_type)
  local submessage = c._wmessage_message(self, k)
  encode_message(submessage, message_type, v)
end

function _writer:int_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_integer(self,k,v)
  end
end

function _writer:real_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_real(self,k,v)
  end
end

function _writer:bool_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_integer(self, k, v and 1 or 0)
  end
end

function _writer:string_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_string(self,k,v)
  end
end

function _writer:message_repeated(k,v, message_type)
  for _,v in ipairs(v) do
    local submessage = c._wmessage_message(self, k)
    encode_message(submessage, message_type, v)
  end
end

function _writer:int32_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_int32(self,k,v)
  end
end

function _writer:int64_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_int64(self,k,v)
  end
end

function _writer:int52_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_int52(self,k,v)
  end
end

function _writer:uint52_repeated(k,v)
  for _,v in ipairs(v) do
    c._wmessage_uint52(self,k,v)
  end
end

_writer[1] = function(msg) return _writer.int end
_writer[2] = function(msg) return _writer.real end
_writer[3] = function(msg) return _writer.bool end
_writer[4] = function(msg) return _writer.string end
_writer[5] = function(msg) return _writer.string end
_writer[6] = function(msg)
  local message = _writer.message
  return  function(self,key , v)
      return message(self, key, v, msg)
    end
end
_writer[7] = function(msg) return _writer.int64 end
_writer[8] = function(msg) return _writer.int32 end
_writer[9] = _writer[5]
_writer[10] = function(msg) return _writer.int52 end
_writer[11] = function(msg) return _writer.uint52 end

_writer[128+1] = function(msg) return _writer.int_repeated end
_writer[128+2] = function(msg) return _writer.real_repeated end
_writer[128+3] = function(msg) return _writer.bool_repeated end
_writer[128+4] = function(msg) return _writer.string_repeated end
_writer[128+5] = function(msg) return _writer.string_repeated end
_writer[128+6] = function(msg)
  local message = _writer.message_repeated
  return  function(self,key, v)
      return message(self, key, v, msg)
    end
end
_writer[128+7] = function(msg) return _writer.int64_repeated end
_writer[128+8] = function(msg) return _writer.int32_repeated end
_writer[128+9] = _writer[128+5]
_writer[128+10] = function(msg) return _writer.int52_repeated end
_writer[128+11] = function(msg) return _writer.uint52_repeated end

local _encode_type_meta = {}

function _encode_type_meta:__index(key)
  local t, msg = c._env_type(P, self._CType, key)
  local func = assert(_writer[t],key)(msg)
  self[key] = func
  return func
end

setmetatable(encode_type_cache , {
  __index = function(self, key)
    local v = setmetatable({ _CType = key } , _encode_type_meta)
    self[key] = v
    return v
  end
})

function encode( message, t , func , ...)
  local encoder = c._wmessage_new(P, message)
  assert(encoder ,  message)
  encode_message(encoder, message, t)
  if func then
    local buffer, len = c._wmessage_buffer(encoder)
    local ret = func(buffer, len, ...)
    c._wmessage_delete(encoder)
    return ret
  else
    local s = c._wmessage_buffer_string(encoder)
    c._wmessage_delete(encoder)
    return s
  end
end

--------- unpack ----------

local _pattern_type = {
  [1] = {"%d","i"},
  [2] = {"%F","r"},
  [3] = {"%d","b"},
  [4] = {"%d","i"},
  [5] = {"%s","s"},
  [6] = {"%s","m"},
  [7] = {"%D","x"},
  [8] = {"%d","p"},
  [10] =  {"%D","d"},
  [11] =  {"%D","u"},
  [128+1] = {"%a","I"},
  [128+2] = {"%a","R"},
  [128+3] = {"%a","B"},
  [128+4] = {"%a","I"},
  [128+5] = {"%a","S"},
  [128+6] = {"%a","M"},
  [128+7] = {"%a","X"},
  [128+8] = {"%a","P"},
  [128+10] = {"%a", "D" },
  [128+11] = {"%a", "U" },
}

_pattern_type[9] = _pattern_type[5]
_pattern_type[128+9] = _pattern_type[128+5]


local function _pattern_create(pattern)
  local iter = string.gmatch(pattern,"[^ ]+")
  local message = iter()
  local cpat = {}
  local lua = {}
  for v in iter do
    local tidx = c._env_type(P, message, v)
    local t = _pattern_type[tidx]
    assert(t,tidx)
    tinsert(cpat,v .. " " .. t[1])
    tinsert(lua,t[2])
  end
  local cobj = c._pattern_new(P, message , "@" .. table.concat(cpat," "))
  if cobj == nil then
    return
  end
  c._add_pattern(GC, cobj)
  local pat = {
    CObj = cobj,
    format = table.concat(lua),
    size = 0
  }
  pat.size = c._pattern_size(pat.format)

  return pat
end

setmetatable(_pattern_cache, {
  __index = function(t, key)
    local v = _pattern_create(key)
    t[key] = v
    return v
  end
})

function unpack(pattern, buffer, length)
  local pat = _pattern_cache[pattern]
  return c._pattern_unpack(pat.CObj , pat.format, pat.size, buffer, length)
end

function pack(pattern, ...)
  local pat = _pattern_cache[pattern]
  return c._pattern_pack(pat.CObj, pat.format, pat.size , ...)
end

function check(typename , field)
  if field == nil then
    return c._env_type(P,typename)
  else
    return c._env_type(P,typename,field) ~=0
  end
end

--------------

local default_cache = {}

-- todo : clear default_cache, v._CObj

local function default_table(typename)
  local v = default_cache[typename]
  if v then
    return v
  end

  v = { __index = assert(decode_message(typename , "")) }

  default_cache[typename]  = v
  return v
end

local decode_message_mt = {}

local function decode_message_cb(typename, buffer)
  return setmetatable ( { typename, buffer } , decode_message_mt)
end

function decode(typename, buffer, length)
  local ret = {}
  local ok = c._decode(P, decode_message_cb , ret , typename, buffer, length)
  if ok then
    return setmetatable(ret , default_table(typename))
  else
    return false , c._last_error(P)
  end
end

local function expand(tbl)
  local typename = rawget(tbl , 1)
  local buffer = rawget(tbl , 2)
  tbl[1] , tbl[2] = nil , nil
  assert(c._decode(P, decode_message_cb , tbl , typename, buffer), typename)
  setmetatable(tbl , default_table(typename))
end

function decode_message_mt.__index(tbl, key)
  expand(tbl)
  return tbl[key]
end

function decode_message_mt.__pairs(tbl)
  expand(tbl)
  return pairs(tbl)
end

local function set_default(typename, tbl)
  for k,v in pairs(tbl) do
    if type(v) == "table" then
      local t, msg = c._env_type(P, typename, k)
      if t == 6 then
        set_default(msg, v)
      elseif t == 128+6 then
        for _,v in ipairs(v) do
          set_default(msg, v)
        end
      end
    end
  end
  return setmetatable(tbl , default_table(typename))
end

local top_level_msgs = {}

function register( buffer)
  c._env_register(P, buffer)

  local tp = 'google.protobuf.FileDescriptorSet'
  local meta_info = decode(tp, buffer)
  -- collect top level msg types
  for _, v in ipairs(meta_info.file) do
    for _, msg in ipairs(v.message_type) do
      table.insert(top_level_msgs, msg)
      local tp
      if v.package ~= '' then
        tp = v.package .. '.' .. msg.name
      else
        tp = msg.name
      end
      top_level_msgs[tp] = msg
    end
  end
end

function register_file(filename)
  local f = assert(io.open(filename , "rb"))
  register(f:read "*a")
  f:close()
end

function enum_id(enum_type, enum_name)
  return c._env_enum_id(P, enum_type, enum_name)
end

function extract(tbl)
    local typename = rawget(tbl , 1)
    local buffer = rawget(tbl , 2)
    if type(typename) == "string" and type(buffer) == "string" then
        if check(typename) then
            expand(tbl)
        end
    end

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            extract(v)
        end
    end
end

default=set_default

--- 查找类型信息
-- upvalue : top_level_msgs list of top level message
-- @string typename : top level 或嵌套的 message type名
-- @return 类型信息
local function find_msg_info(typename)
  local _, _, bn, optdot, sn = typename:find('([^%.]+%.[^%.]+)(%.?)(.*)')
  local tt = bn and top_level_msgs[bn]
  if not tt then
    _, _, bn, optdot, sn = typename:find('([^%.]+)(%.?)(.*)')
    tt = bn and top_level_msgs[bn]
  end

  if tt then
    if optdot == '' then
      return tt
    else
      local next_type_name = sn:gmatch('([^%.]+)%.?')

      local function go(stt, tv)
        for _, v in ipairs(stt.nested_type) do
          if v.name == tv then
            tv = next_type_name()
            if tv then
              return go(v, tv)
            else
              return v
            end
          end
        end
      end

      return go(tt, assert(next_type_name(), 'invalid input: ' .. typename))
    end
  end
end

-- TODO 修复保留字段名限制后，要更新此处
local function copy_table(nt, ot)
  for k, v in next, ot, nil do
    if k ~= '_Parent' then
      nt[k] = type(v) == 'table' and copy_table({}, v) or v
    end
  end
  nt._CType = nil
  nt._CObj = nil
  return nt
end


-- @msg : {typename, buffer} with meta {index, pairs} to expand
-- 这个表作为default table的子表表缓存起来继续使用，需要复制
local function build_msg(msg)
  local tti = assert(find_msg_info(msg._CType))
  for _, subfield in ipairs(tti.field) do
    local field_name = subfield.name
    local value = msg[field_name]
    if type(value) == 'table' then
      msg[field_name] = copy_table({}, build_msg(value))
    else
      msg[field_name] = value
    end
  end
  return msg
end

local function build(msg)
  local info = assert(find_msg_info(msg._CType))
  local msgmtidx = assert(getmetatable(msg)).__index
  for _, field in ipairs(info.field) do
    local field_name = field.name
    local raw_value = rawget(msg, field_name)
    if raw_value == nil then
      local value = msg[field_name]
      if type(value) == 'table' then
        msg[field_name] = copy_table({}, build_msg(value))
      else
        msg[field_name] = value
      end
    else
      if type(raw_value) == 'table' then
        build_msg(raw_value)
        -- 缓存默认值到 root msg的元表
        msgmtidx[field_name] = getmetatable(raw_value).__index
        setmetatable(raw_value, nil)
      end
    end
  end
  return setmetatable(msg, nil)
end

function decode_ex(typename, buffer, length)
  local msg, err = decode(typename, buffer, length)
  if msg then
    return build(msg)
  else
    return false, err
  end
end



