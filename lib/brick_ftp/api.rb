module BrickFTP
  module API
    class Error < StandardError
    end

    class NoSuchAPI < Error
    end
  end
end
