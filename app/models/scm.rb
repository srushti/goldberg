module Scm
  def self.provider(scm)
    self.const_get(scm.titlecase)
  end
end
