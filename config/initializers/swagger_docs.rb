Swagger::Docs::Config.register_apis(
    {
        "1.0" => {
            # the extension used for the API
            :api_extension_type => :json,
            # the output location where your .json files are written to
            :api_file_path => "public/api/1.0/",
            # the URL base path to your API
            :base_path => "https://foodapp-pos.herokuapp.com/",
            # if you want to delete all .json files at each generation
            :clean_directory => true,
            # add custom attributes to api-docs
            :attributes => {
                :info => {
                    "title" => "Black List",
                    "description" => "",
                }
            }
        }
    })

Swagger::Docs::Config.base_api_controller = ApplicationController
class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    "api/#{api_version}/#{path}"
  end
end
