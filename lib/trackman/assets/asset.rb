module Trackman
  module Assets
    class Asset
      extend AssetFactory, Trackman::Components::Conventions
      extend Trackman::Components::Diffable, Trackman::Components::Shippable
      include Comparable
      
      def initialize attributes = {}
        @assets = []
        
        self.path = attributes[:path]
        self.virtual_path = attributes[:virtual_path]
      end
      
      attr_accessor :virtual_path
      attr_reader :path, :assets

      def to_remote(id = nil)
        RemoteAsset.create(:path => @path, :virtual_path => self.virtual_path, :id => id)
      end

      def ==(other)
        return false if other.nil?
        other_path = other.path.is_a?(Pathname) ? other.path : Pathname.new(other.path)
        path_equal = other_path.to_s == path.to_s || path.cleanpath == other_path.cleanpath
        vp_equal = virtual_path.to_s == other.virtual_path.to_s
        
        path_equal && vp_equal
      end

      def <=>(another)
        result = 0

        if self.path.extname == '.html' && another.path.extname == '.html'
          result = self.path.to_s <=> another.path.to_s  
        elsif @path.extname == '.html' || another.path.extname == '.html'  
          result += 1 if self.path.extname == '.html'
          result -= 1 if another.path.extname == '.html'
        elsif is_child_of(another)
          result += -1
        elsif another.is_child_of(self)
          result += 1
        else
          result = self.path.to_s <=> another.path.to_s  
        end  

        result
      end
      
      def is_child_of(parent)
        parent.assets.include? self
      end
      
      def to_s
        "\n<#{self.class}>:\npath='#{path}'\nfile_hash='#{file_hash}'\nvirtual_path='#{virtual_path}'"
      end
      
      def self.all
        return [] unless maintenance_path.exist?

        assets = [maintenance_page] + maintenance_page.assets 
        assets = assets + [error_page] + error_page.assets if error_path.exist?

        assets.uniq{|a| a.path.realpath }.sort 
      end

      def self.sync
        local = Asset.all
        remote = RemoteAsset.all

        diff_result = diff(local, remote)
        ship diff_result
        
        true
      end

      def self.autosync
        autosync = ENV['TRACKMAN_AUTOSYNC'] || true
        autosync = autosync !~ /(0|false|FALSE)/ unless autosync.is_a? TrueClass
        
        if Object.const_defined?(:Rails)
          autosync = autosync && !(Rails.env.development? || Rails.env.test?)
        end 
        
        begin
          return sync if autosync
        rescue Exception => ex
          begin
            Trackman::Utility::Debugger.log_exception ex
          rescue Exception => ex2
            puts ex2
          ensure
            return false
          end
        end
        autosync
      end

      protected
        def validate_path?
          true
        end
        def path=(value)
          value = Pathname.new value unless value.nil? || value.is_a?(Pathname)
          if validate_path?
            unless value && value.exist? && value.file?
              raise Errors::AssetNotFoundError, "The path '#{value}' is invalid or is not a file"
            end
          end
          @path = value
        end
    end 
  end
end
