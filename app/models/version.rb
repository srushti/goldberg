module Version
  unless defined? MAJOR
    MAJOR  = 1
    MINOR  = 0
    TINY   = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
