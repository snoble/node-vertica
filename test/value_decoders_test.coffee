vows    = require 'vows'
assert  = require 'assert'

Vertica       = require('../src/vertica')
ValueDecoders = require('../src/value_decoders')

vow = vows.describe('Value Decoders')

vow.addBatch
  'string decoders':
  
    'timestamp with timezone': ->
      # Negative timezone
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57, 32, 49, 55, 58, 51, 57, 58, 52, 53, 46, 54, 54, 53, 48, 53, 49, 45, 48, 50, 58, 51, 48])
      assert.deepEqual ValueDecoders.string.timestamp(data), new Date(Date.UTC(2011, 7, 29, 20, 09, 45, 665))

      # Positive timezone
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57, 32, 50, 50, 58, 49, 50, 58, 52, 48, 46, 48, 51, 50, 50, 43, 48, 50])
      assert.deepEqual ValueDecoders.string.timestamp(data), new Date(Date.UTC(2011, 7, 29, 20, 12, 40, 32))

      # UTC = no offset
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57, 32, 50, 48, 58, 49, 52, 58, 52, 53, 46, 54, 55, 49, 52, 52, 55, 43, 48, 48])
      assert.deepEqual ValueDecoders.string.timestamp(data), new Date(Date.UTC(2011, 7, 29, 20, 14, 45, 671))


    'timestamp without timezone': ->
      # Use UTC by default
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57, 32, 49, 55, 58, 51, 52, 58, 52, 48, 46, 53, 52, 54, 54, 48, 53])
      assert.deepEqual ValueDecoders.string.timestamp(data), new Date(Date.UTC(2011, 7, 29, 17, 34, 40, 547))

      # Set timezone offset to +2
      Vertica.setTimezoneOffset("+2")
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57, 32, 49, 55, 58, 51, 52, 58, 52, 48, 46, 53, 52, 54, 54, 48, 53])
      assert.deepEqual ValueDecoders.string.timestamp(data), new Date(Date.UTC(2011, 7, 29, 15, 34, 40, 547))
      Vertica.setTimezoneOffset(null)

    'date': ->
      data = new Buffer([50, 48, 49, 49, 45, 48, 56, 45, 50, 57])
      assert.deepEqual ValueDecoders.string.date(data), new Vertica.Date(2011, 8, 29)

    'time': ->
      data = new Buffer([48, 52, 58, 48, 53, 58, 48, 54])
      assert.deepEqual ValueDecoders.string.time(data), new Vertica.Time(4,5,6)


    'string': ->
      data = new Buffer([104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100])
      assert.deepEqual ValueDecoders.string.string(data), 'hello world'
      
    'integer': ->
      data = new Buffer([49])
      assert.deepEqual ValueDecoders.string.integer(data), 1
      
    'real': ->
      data = new Buffer([49, 46, 51, 51])
      assert.deepEqual ValueDecoders.string.real(data), 1.33
    
    'numeric': ->
      data = new Buffer([49, 48, 46, 53])
      assert.deepEqual ValueDecoders.string.real(data), 10.5

    'boolean': ->
      assert.deepEqual ValueDecoders.string.boolean(new Buffer([116])), true
      assert.deepEqual ValueDecoders.string.boolean(new Buffer([102])), false


vow.export(module)
      