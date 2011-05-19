module Version
  unless defined? MAJOR
    MAJOR  = 0
    MINOR  = 9
    TINY   = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
