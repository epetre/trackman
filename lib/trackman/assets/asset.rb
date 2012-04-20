module Trackman
  module Assets
    class Asset
      extend Components::AssetFactory
      extend Components::Conventions
      extend Components::Diffable
      extend Components::Shippable
      include Components::Hashable
      include Comparable
      
      def initialize attributes = {}
        super()
        path = attributes[:path]
        path = Pathname.new path unless path.nil? || path.is_a?(Pathname)

        if validate_path?
          unless path && path.exist? && path.file?
            raise Errors::AssetNotFoundError, "The path '#{path}' is invalid or is not a file"
          end
        end

        @path = path
        @assets = []  
      end
      
      def file
        File.open(path)
      end
      
      attr_reader :path, :assets

      def to_remote
        RemoteAsset.new(:path => path)
      end

      def ==(other)
        return false if other.nil?
        other_path = other.path.is_a?(Pathname) ? other.path : Pathname.new(other.path) 
        other_path.to_s == path.to_s || path.realpath == other_path.realpath
      end

      def <=>(another)
        result = 0
        if self.path.extname == '.html' || another.path.extname == '.html' 
          result += 1 if self.path.extname == '.html'
          result -= 1 if another.path.extname == '.html'
        elsif is_child_of(another)
          result += -1
        elsif another.is_child_of(self)
          result += 1
        end  

        result
      end
      
      def is_child_of(parent)
        parent.is_a?(Components::CompositeAsset) && parent.assets.include?(self)
      end

      def self.all
        if maintenance_path.exist?
          
          assets = [maintenance_page] + maintenance_page.assets 
          assets = assets + [error_page] + error_page.assets if error_path.exist?
          
          return assets.uniq{|a| a.path.realpath }.sort
        else
          return []
        end  
      end

      def self.sync
        local = Asset.all
        #puts "local: #{local.collect{|x| x.path}}"
        remote = RemoteAsset.all
        #puts "remote: #{remote.collect{|x| x.path}}"
        diff_result = diff(local, remote) 
        #puts "\n\n\nDIFFFFFFFF -----------------"
        #puts diff_result.inspect
        ship diff_result
        
        true
      end

      def self.autosync
        autosync = ENV['TRACKMAN_AUTOSYNC'] || true
        autosync = autosync !~ /(0|false|FALSE)/ unless autosync.is_a? TrueClass
        begin
          return sync if autosync
        rescue
          return false
        end
        autosync
      end
      protected
        def validate_path?
          true
        end
    end 
  end
end