# -*-mode: ruby; coding: utf-8 -*-

module Nand
  module Util
    class ::Object
      def whoami
        self.is_a?(Class) ? self : self.class
      end
      def short_name
        whoami.to_s.split("::").last
      end
      def full_name
        whoami.to_s
      end
      def parent_name
        self.parent_class.to_s
      end
      def parent_class(upper = 1 )
        whoami.to_s.split("::")[0...-1*upper].inject( ::Object ){ |parent, child| parent.const_get( child ) }
      end
      alias :namespace :parent_class
    end
  end
end

