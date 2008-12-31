#
#  SpeechController.rb
#  RSpactor
#
#  Created by Chris Bailey on 12/24/08.
#

require 'osx/cocoa'

class SpeechController < OSX::NSObject
  attr_accessor :speechSynthesizer

	def initialize
		receive :spec_run_example_failed,   :specRunFinishedSingleSpec
    receive :spec_run_dump_summary,     :specRunFinishedWithSummaryDump    
    receive :error,                     :errorPosted    
		
		@speechSynthesizer = OSX::NSSpeechSynthesizer.alloc.initWithVoice(@voiceForError)
	end
	
	def specRunFinishedSingleSpec(notification)    
    return unless speak_results?
		
    spec = notification.userInfo.first
		speak(spec.state)
  end
  
  def specRunFinishedWithSummaryDump(notification)    
    return unless speak_results?

    duration, example_count, failure_count, pending_count = notification.userInfo
		
		if failure_count.to_i > 0
			speak(:failed, failure_count)
		elsif pending_count.to_i > 0
			speak(:pending, pending_count)
		else
			speak(:pass, example_count)
		end
  end

  def errorPosted(notification)
    return unless speak_results?

    speak(:error)    
  end


	protected
			
	def speak_results?
		$app.default_from_key(:speech_use_speech) == '1'
	end
	
	def speak(kind, amount=0)
		case kind
		when :pass
		  setVoiceTo :speech_voice_tests_pass
			speechSynthesizer.startSpeakingString($app.default_from_key(:speech_phrase_tests_pass).sub(/\?/, amount.to_s))
		when :failed
		  setVoiceTo :speech_voice_tests_fail
			speechSynthesizer.startSpeakingString($app.default_from_key(:speech_phrase_tests_fail).sub(/\?/, amount.to_s))
		when :pending
		  setVoiceTo :speech_voice_tests_pending
			speechSynthesizer.startSpeakingString($app.default_from_key(:speech_phrase_tests_pending).sub(/\?/, amount.to_s))
		when :error
		  setVoiceTo :speech_voice_tests_fail
			speechSynthesizer.startSpeakingString('SpecRunner aborted. Please have a look at the output for more information.')
		end
	end
	
	def setVoiceTo(key)
	  if $app.default_from_key(key).empty?
	    @speechSynthesizer.setVoice(OSX::NSSpeechSynthesizer.defaultVoice)
	  else
		  @speechSynthesizer.setVoice("com.apple.speech.synthesis.voice." + $app.default_from_key(key))
		end
  end
end