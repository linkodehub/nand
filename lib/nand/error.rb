# -*-mode: ruby; coding: utf-8 -*-

module Nand
  module Error
    class Base < StandardError
      require 'nand/util/object'
      def readable
        self.short_name.gsub(/([a-z0-9]+?)([A-Z][a-z]*?|[A-Z])/, '\1 \2').gsub(/([A-Z]+)([A-Z][a-z0-9]+?)/, '\1 \2')
      end
      def to_s; "#{readable} #{super}" end
    end
    class NotFound             < Base; end
    class NotExecutable        < Base; end
    class IllegalOutputFile    < Base; end
    class IllegalInputFile     < Base; end
    class NotFoundPlugin       < Base; end
    class NotImplemented       < Base; end
    class Unregistered         < Base; end
    class AlreadyRegsteredName < Base; end
  end
end

