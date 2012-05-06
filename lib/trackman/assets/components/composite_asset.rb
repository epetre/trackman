module Trackman
  module Assets
    module Components
      module CompositeAsset
        
        def assets
          my_assets = []

          children_paths.select{|p| p.internal_path? }.each do |p| 
            asset = Asset.create(:path => to_path(p))  
            my_assets << asset 
            my_assets = my_assets.concat(asset.assets.select{|a| !my_assets.include?(a) })   
          end
          my_assets
        end
        
        def inner_css_paths
          @@url ||= /url\(['"]?(?<url>[^'")]+)['"]?\)/
          @@import ||= /url\(['"]?[^'"]+['"]?\)/

          data.scan(@@import).collect{|x| @@url.match(x)[:url] }
        end
        
        protected
          def to_path(str_path)
            return Pathname.new str_path if File.exist? str_path
            Pathname.new "#{path.parent}/#{str_path}"
          end    
      end
    end
  end
end

class String
  def internal_path? 
    self !~ /^http/
  end 
end