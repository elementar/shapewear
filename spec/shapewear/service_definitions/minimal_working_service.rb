# This class represents a minimal working service, without the use of any of the Shapewear specific DSL.
# It is used to test the Convention-over-Configuration-ness of Shapewear.
class MininalWorkingService
  include Shapewear

  def hello_world
    "hello"
  end
end
