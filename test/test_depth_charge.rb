require File.dirname(__FILE__) + '/test_helper.rb'

class TestDepthCharge < Test::Unit::TestCase

  def test_retrieve_local_gems_should_run_gem_list_local
    DepthCharge.expects(:`).returns( "\n*** LOCAL GEMS ***\n\nabstract (1.0.0)\nactionmailer (2.0.2, 2.0.1, 1.3.3)\n")
    gems = DepthCharge.local_gems

    assert_equal 'abstract', gems[0]
    assert_equal 'actionmailer', gems[1]
  end

  def test_retrieve_remote_gems_should_run_gem_list_remote
    File.expects(:exists?).returns(false)
    File.expects(:open).returns(true)
    DepthCharge.expects(:puts).returns(true)
    DepthCharge.expects(:`).returns( "*** REMOTE GEMS ***\n\nempty\naalib-ruby (1.0)\nabstract (1.0)")
    gems = DepthCharge.remote_gems

    assert_equal 'aalib-ruby', gems[0]
    assert_equal 'abstract', gems[1]
  end
  
  def test_remote_gems_should_hit_cache
    DepthCharge.expects(:`).never
    File.expects(:open).returns(true)
    gems = DepthCharge.remote_gems
  end
end
