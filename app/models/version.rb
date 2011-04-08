module Version
  unless defined? MAJOR
    MAJOR  = 0
    MINOR  = 0
    TINY   = 1
    BUILD = nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
