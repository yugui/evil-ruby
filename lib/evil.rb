# vim:sw=2
# Written in 2004 by Florian Gross <flgr@ccan.de> and
# Mauricio Julio Fernández Pradier <batsman.geo@yahoo.com>
#
# This is licensed under the same license as Ruby.

module RubyInternal
  Is_1_8 = RUBY_VERSION[/\A1.[678]/]
end

require 'dl'
unless RubyInternal::Is_1_8
  require 'dl/value'
  require 'dl/import'
end
require 'dl/struct'

# Provides low-level access to Ruby's internals. Be
# careful when using this directly, because you can
# break Ruby with it.
module RubyInternal
  DL::CPtr = DL::PtrData if Is_1_8
  DL::SIZEOF_LONG = DL.sizeof("l") if Is_1_8
  
  unless Is_1_8
    class ::DL::CPtr
      alias :old_store :[]=
      def []=(idx, *args)
        if args.size == 1 and args[0].is_a?(String) then
          args[0] = args[0].ord
        end
        
        old_store(idx, *args)
      end
    end
  end
 
  extend self
  importer = Is_1_8 ? DL::Importable : DL::Importer
  extend importer

  dlload()
  
  if Is_1_8
    def typealias(new, old)
      super(new, nil, nil, nil, old)
    end
  end

  Qfalse = 0
  Qtrue  = 2
  Qnil   = 4
  Qundef = 6

  T_NONE   = 0x00
  T_NIL    = 0x01
  T_OBJECT = 0x02
  T_CLASS  = 0x03
  T_ICLASS = 0x04
  T_MODULE = 0x05
  T_FLOAT  = 0x06
  T_STRING = 0x07
  T_REGEXP = 0x08
  T_ARRAY  = 0x09
  T_FIXNUM = 0x0a
  T_HASH   = 0x0b
  T_STRUCT = 0x0c
  T_BIGNUM = 0x0d
  T_FILE   = 0x0e

  if Is_1_8
    T_TRUE   = 0x20
    T_FALSE  = 0x21
    T_DATA   = 0x22
    T_MATCH  = 0x23
    T_SYMBOL = 0x24

    T_BLOCK  = 0x3b
    T_UNDEF  = 0x3c
    T_VARMAP = 0x3d
    T_SCOPE  = 0x3e
    T_NODE   = 0x3f

    T_MASK   = 0x3f
  else # 1.9 or higher
    T_TRUE   = 0x10
    T_FALSE  = 0x11
    T_DATA   = 0x12
    T_MATCH  = 0x13
    T_SYMBOL = 0x14

    T_BLOCK  = 0x1b
    T_UNDEF  = 0x1c
    T_VARMAP = 0x1d
    T_SCOPE  = 0x1e
    T_NODE   = 0x1f

    T_MASK   = 0x1f
  end # constants

  typealias "VALUE", "unsigned long"
  typealias "ID", "unsigned long"
  typealias "ulong", "unsigned long"
  Basic = ["long flags", "VALUE klass"]

  RBasic = struct Basic

  RObject = struct(Basic + [
    "st_table *iv_tbl"    
  ])

  RClass = struct(Basic + [
    "st_table *iv_tbl",
    "st_table *m_tbl",
    "VALUE super"
  ])

  RModule = RClass

  RFloat = struct(Basic + [
    "double value"
  ])

  RString = struct(Basic + [
    "long len",
    "char *ptr",
    "long capa"
  ])

  RArray = struct(Basic + [
    "long len",
    "long capa",
    "VALUE *ptr"
  ])

  RRegexp = struct(Basic + [
    "re_pattern_buffer *ptr",
    "long len",
    "char *str"
  ])

  RHash = struct(Basic + [
    "st_table *tbl",
    "int iter_lev",
    "VALUE ifnone"
  ])

  RFile = struct(Basic + [
    "OpenFile *fptr"
  ])

  RData = struct(Basic + [
    "void *dmark",
    "void *dfree",
    "void *data"
  ])

  RStruct = struct(Basic + [
    "long len",
    "VALUE *ptr"
  ])

  RBignum = struct(Basic + [
    "char sign",
    "long len",
    "void *digits"
  ])

  DMethod = struct [
    "VALUE klass",
    "VALUE rklass",
    "long id",
    "long oid",
    "void *body"
  ]

  FrameBase = [
    "VALUE frame_self",
    "int frame_argc",
    "VALUE *frame_argv",
    "ID frame_last_func",
    "ID frame_orig_func",
    "VALUE frame_last_class",
    "FRAME *frame_prev",
    "FRAME *frame_tmp",
    "RNode *frame_node",
    "int frame_iter",
    "int frame_flags",
    "ulong frame_uniq"
  ]

  Frame = struct FrameBase

  Block = struct([
    "NODE *var",
    "NODE *body",
    "VALUE self",
  ] + FrameBase + [
    "SCOPE *scope",
    "VALUE klass",
    "NODE *cref",
    "int iter",
    "int vmode",
    "int flags",
    "int uniq",
    "RVarmap *dyna_vars",
    "VALUE orig_thread",
    "VALUE wrapper",
    "VALUE block_obj",
    "BLOCK *outer",
    "BLOCK *prev"
  ])

  STD_HASH_TYPE = struct [
    "void *compare",
    "void *hash"
  ]

  typealias "ST_DATA_T", "unsigned long"

  ST_TABLE_ENTRY = struct [
    "int hash",
    "ST_DATA_T key",
    "ST_DATA_T record",
    "ST_TABLE_ENTRY *next"
  ]

  ST_TABLE = struct [
    "ST_HASH_TYPE *type",
    "int num_bins",
    "int num_entries",
    "ST_TABLE_ENTRY **bins"
  ]

  FL_USHIFT    = 11
  FL_USER0     = 1 << (FL_USHIFT + 0)
  FL_USER1     = 1 << (FL_USHIFT + 1)
  FL_USER2     = 1 << (FL_USHIFT + 2)
  FL_USER3     = 1 << (FL_USHIFT + 3)
  FL_USER4     = 1 << (FL_USHIFT + 4)
  FL_USER5     = 1 << (FL_USHIFT + 5)
  FL_USER6     = 1 << (FL_USHIFT + 6)
  FL_USER7     = 1 << (FL_USHIFT + 7)

  FL_SINGLETON = FL_USER0
  FL_MARK      = 1 << 6
  FL_FINALIZE  = 1 << 7
  FL_TAINT     = 1 << 8
  FL_EXIVAR    = 1 << 9
  FL_FREEZE    = 1 << 10

  # Executes a block of code that changes
  # internal Ruby structures. This will
  # make sure that neither the GC nor other
  # Threads are run while the block is
  # getting executed.
  def critical
    begin
      if Is_1_8 then
        old_critical = Thread.critical
        Thread.critical = true
      else
        # Is it OK to do nothing on 1.9?
      end
      
      disabled_gc = !GC.disable

      yield
    ensure
      GC.enable if disabled_gc
      Thread.critical = old_critical if Is_1_8
    end
  end

  module EmptyModule; end
  def empty_iclass_ptr(force_new = false)
    @empty_iclass_ptr ||= nil # avoid warning
    return @empty_iclass_ptr if @empty_iclass_ptr and not force_new
    result = Object.new
    iptr = result.internal_ptr
    ires = result.internal
    newires = RClass.new(result.internal_ptr)
    critical do
      ires.flags &= ~T_MASK
      ires.flags |= T_ICLASS
      ires.klass = EmptyModule.internal_ptr.to_i
      newires.m_tbl = EmptyModule.internal.m_tbl
    end
    @empty_iclass_ptr = iptr
    return iptr
  end
end

class Object
  # Returns the singleton class of an Object.
  # This is just a simple convenience method.
  #
  #   obj = Object.new
  #   obj.singleton_class.class_eval do
  #     def x; end
  #   end
  #   obj.respond_to?(:x) # => true
  def singleton_class
    class << self; self; end
  end
  alias :meta_class :singleton_class

  def internal_class
    # we use this instead of a "cleaner" method (such as a 
    # hash with class => possible flags associations) because
    # (1) the number of internal types won't change
    # (2) it'd be slower
    case internal_type
    when RubyInternal::T_OBJECT 
      RubyInternal::RObject
    when RubyInternal::T_CLASS,  RubyInternal::T_ICLASS, RubyInternal::T_MODULE 
      RubyInternal::RModule
    when RubyInternal::T_FLOAT  
      RubyInternal::RFloat
    when RubyInternal::T_STRING 
      RubyInternal::RString
    when RubyInternal::T_REGEXP 
      RubyInternal::RRegexp
    when RubyInternal::T_ARRAY  
      RubyInternal::RArray
    when RubyInternal::T_HASH   
      RubyInternal::RHash
    when RubyInternal::T_STRUCT 
      RubyInternal::RStruct
    when RubyInternal::T_BIGNUM 
      RubyInternal::RBignum
    when RubyInternal::T_FILE   
      RubyInternal::RFile
    when RubyInternal::T_DATA
      RubyInternal::RData
    else
      raise "No internal class for #{self}"
    end
  end

  def internal_type
    case self
      when Fixnum then RubyInternal::T_FIXNUM
      when NilClass then RubyInternal::T_NIL
      when FalseClass then RubyInternal::T_FALSE
      when TrueClass then RubyInternal::T_TRUE
      when Symbol then RubyInternal::T_SYMBOL
      else
        RubyInternal::RBasic.new(self.internal_ptr).flags & RubyInternal::T_MASK
    end
  end

  def internal_ptr(*args)
    raise(ArgumentError, "Can't get pointer to direct values.") \
      if direct_value?
    pos = self.object_id * 2
    DL::CPtr.new(pos, *args)
  end

  def internal
    raise(ArgumentError, "Can't get internal representation" +
                         " of direct values") \
      if direct_value?

    propagate_magic = nil # forward "declaration"
    do_magic = lambda do |obj, id|
      addr = obj.instance_eval { send(id) }
      sklass = class << obj; self end 
      sklass.instance_eval do
        define_method(id) do
          case addr
          when 0
            return nil
          else
            begin
              r = RubyInternal::RClass.new DL::CPtr.new(addr, 5 * DL::SIZEOF_LONG)
            rescue RangeError
              r = RubyInternal::RClass.new DL::CPtr.new(addr - 2**32, 5 * DL::SIZEOF_LONG)
            end
            propagate_magic.call r, true
          end
          class << r; self end.instance_eval { define_method(:to_i) { addr } }
          r
        end
      end
    end

    propagate_magic = lambda do |obj, dosuper|
      do_magic.call(obj, :klass)
      do_magic.call(obj, :super) if dosuper
    end

    klass = internal_class
    r = klass.new(internal_ptr)
    
    case klass
    when RubyInternal::RClass, RubyInternal::RModule
      propagate_magic.call r, true
    else
      propagate_magic.call r, false
    end
    r
  end

  # Unfreeze a frozen Object. You will be able to make
  # changes to the object again.
  #
  #   obj = "Hello World".freeze
  #   obj.frozen? # => true
  #   obj.unfreeze
  #   obj.frozen? # => false
  #   obj.sub!("World", "You!")
  #   obj # => "Hello You!"
  def unfreeze
    if $SAFE > 0
      raise(SecurityError, "Insecure operation `unfreeze' at level #{$SAFE}")
    end

    return self if direct_value?

    self.internal.flags &= ~RubyInternal::FL_FREEZE
    return self
  end

  # Returns true if the Object is one of the Objects which
  # Ruby stores directly. Fixnums, Symbols, true, false and
  # nil all are direct values.
  #
  #   5.direct_value?     # => true
  #   :foo.direct_value?  # => true
  #   "foo".direct_value? # => false
  #   5.0.direct_value?   # => false
  def direct_value?
    [Fixnum, Symbol, NilClass, TrueClass, FalseClass].any? do |klass|
       klass === self
    end
  end

  alias :immediate_value? :direct_value?

  # Changes the class of an Object to a new one. This will
  # change the methods available on the Object.
  #
  #   foo_klass = Class.new {}
  #   obj = Object.new
  #   obj.class = foo_klass
  #   obj.class # => foo_klass
  def class=(new_class)
    raise(ArgumentError, "Can't change class of direct value.") \
      if direct_value?
    raise(ArgumentError, "Class has to be a Class.") \
      unless new_class.is_a? Class
    if self.class.to_internal_type and
       new_class.to_internal_type and
       self.class.to_internal_type != new_class.to_internal_type
      msg = "Internal type of class isn't compatible with " + 
            "internal type of object."
      raise(ArgumentError, msg)
    end
    if self.class.to_internal_type == RubyInternal::T_DATA
      msg = "Internal type of class isn't compatible with " + 
            "internal type of object. (Both are T_DATA, but " +
            "that doesn't imply that they're compatible.)"
      raise(ArgumentError, msg)
    end
    self.internal.klass = new_class.internal_ptr.to_i
    return self
  end

  # Shares the instance variables of two Objects with each
  # other. If you make a change to such shared instance
  # variables they will change at both Objects.
  def share_instance_variables(from_obj)
    raise(ArgumentError, "Can't share instance variables of" +
                         "direct values") \
      if direct_value?
    #FIXME: memleak (?)
    self.internal.iv_tbl = from_obj.internal.iv_tbl
    return instance_variables
  end

  # The Object will acquire a copy of +obj+'s singleton methods.
  def grab_singleton_methods(obj)
    original_sklass = class << obj; self end  # make sure the singleton class is there
    RubyInternal::critical do
      original_sklass.internal.flags &= ~ RubyInternal::FL_SINGLETON
      class << self; self end.module_eval{ include original_sklass.as_module }
      original_sklass.internal.flags |= RubyInternal::FL_SINGLETON
    end
  end
end

class Class
  # Changes the super class of a Class.
  def superclass=(new_class)
    k1 = superclass
    if new_class.nil?
      self.internal.super = RubyInternal.empty_iclass_ptr.to_i
    else
      raise(ArgumentError, "Value of class has to be a Class.") \
        unless new_class.is_a?(Class)
      raise(ArgumentError, "superclass= would create circular " +
                           "inheritance structure.") \
        if new_class.ancestors.include?(self)
      raise(ArgumentError, "Superclass type incompatible with own type.") \
        if new_class.to_internal_type != self.to_internal_type
      self.internal.super = new_class.internal_ptr.to_i
    end
    # invalidate the method cache
    k1.instance_eval { public :__send__ rescue nil }
  end

  def to_internal_type
    begin
      self.allocate.internal.flags & RubyInternal::T_MASK
    rescue
      if self.superclass
        self.superclass.to_internal_type 
      else
        nil
      end
    end
  end

  # Will return the Class converted to a Module.
  def as_module
    result = nil
    RubyInternal.critical do
      fl_singleton = self.internal.flags & RubyInternal::FL_SINGLETON
      begin
        self.internal.flags &= ~ RubyInternal::FL_SINGLETON
        result = self.clone
      ensure
        self.internal.flags |= fl_singleton
      end
      o = RubyInternal::RObject.new(result.internal_ptr)
      o.flags &= ~ RubyInternal::T_MASK
      o.flags |= RubyInternal::T_MODULE
      o.klass = Module.internal_ptr.to_i
    end
    return result
  end

  # This will allow your Classes to inherit from multiple
  # other Classes. If two Classes define the same method
  # the last one will be used.
  #
  #   bar_klass = Class.new { def bar; end }
  #   qux_klass = Class.new { def qux; end }
  #   foo_klass = Class.new do
  #     inherit bar_klass, qux_klass
  #   end
  #   foo = foo_klass.new
  #   foo.respond_to?(:bar) # => true
  #   foo.respond_to?(:qux) # => true
  def inherit(*sources)
    sources.each do |klass|
      raise(ArgumentError, "Cyclic inherit detected.") \
        if klass.ancestors.include?(self)
      raise(ArgumentError, "Can only inherit from Classes.") \
        unless klass.is_a?(Class)
      # the following is needed cause otherwise we could end up inheriting
      # e.g. a method from String that would assume the object has some
      # internal structure (RString) and crash otherwise...
      unless klass.to_internal_type == self.to_internal_type
        raise(ArgumentError, "Inherit needs consistent internal types.")
      end
      include klass.as_module
      extend klass.singleton_class.as_module
    end
  end
  private :inherit
end

# Like Object, but this provides no methods at all.
# You can derivate your own Classes from this Class
# if you want them to have no preset methods.
#
#   klass = Class.new(KernellessObject) { def inspect; end }
#   klass.new.methods # raises NoMethodError
#
# Classes that are derived from KernellessObject
# won't call #initialize from .new by default.
#
# It is a good idea to define #inspect for subclasses,
# because Ruby will go into an endless loop when trying
# to create an exception message if it is not there.
class KernellessObject
  class << self
    def to_internal_type; ::Object.to_internal_type; end

    def allocate
      obj = ::Object.allocate
      obj.class = self
      return obj
    end

    alias :new :allocate
  end

  self.superclass = nil
end

class UnboundMethod
  # Like UnboundMethod#bind this will bind an UnboundMethod
  # to an Object. However this variant doesn't enforce class
  # compatibility when it isn't needed. (It still needs
  # compatible internal types however.)
  #
  # Currently it's also generally impossible to force_bind a
  # foreign method to immediate objects.
  #
  # Here's an example:
  # 
  #   foo_klass = Class.new do
  #     def greet; "#{self.inspect} says 'Hi!'"; end
  #   end
  #   obj = []
  #   greet = foo_klass.instance_method(:greet)
  #   greet.bind(obj).call # raises TypeError
  #   greet.force_bind(obj).call # => "[] says 'Hi!'"
  def force_bind(obj)
    data = self.internal.data
    source_class_addr = RubyInternal::DMethod.new(data).klass
    source_class = ObjectSpace._id2ref(source_class_addr / 2)

    if [Fixnum, Symbol, NilClass, TrueClass, FalseClass].any? do |klass|
      klass <= source_class
    end then
      if not obj.is_a?(source_class) then
        msg = "Immediate source class and non-immediate new " +
              "receiver are incompatible"
        raise(ArgumentError, msg)
      else
        return self.bind(obj)
      end
    end

    if source_class.to_internal_type and
       source_class.to_internal_type != RubyInternal::T_OBJECT and
       source_class.to_internal_type != obj.class.to_internal_type
      msg = "Internal type of source class and new receiver " + 
            "are incompatible"
      raise(ArgumentError, msg)
    end

    result = nil
    RubyInternal.critical do
      prev_class = obj.internal.klass.to_i
      begin
        internal_obj = obj.internal
        begin
          internal_obj.klass = source_class_addr
          result = self.bind(obj)
        ensure
          internal_obj.klass = prev_class
        end
      rescue TypeError
        result = self.bind(obj)
      end
    end

    return result
  end
end

class Proc
  def self
    eval "self", self
  end

  # FIXME: look into possible signedness issues for large Fixnums (2**30 and higher)
  def self=(new_self)
    new_self_ptr = new_self.object_id
    unless new_self.direct_value?
      new_self_ptr = new_klass_ptr * 2 
      # new_self_ptr +=  2 ** 32 if new_klass_ptr < 0 # FIXME: needed?
    end
    new_klass_ptr = class << new_self; self; end.object_id * 2 rescue nil.object_id
    data = RubyInternal::RData.new(internal_ptr).data
    block = RubyInternal::Block.new(data)

    RubyInternal.critical do
      block.self = new_self_ptr
      block.klass = new_klass_ptr
    end

    return new_self
  end
  alias :context= :self=
end
