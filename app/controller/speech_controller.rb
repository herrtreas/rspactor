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
    Notification.subscribe self, :spec_run_dump_summary => :specRunFinishedWithSummaryDump    
    Notification.subscribe self, :error                 => :errorPosted    
		
		@speechSynthesizer = OSX::NSSpeechSynthesizer.alloc.initWithVoice(@voiceForError)
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
		Defaults.get(:speech_use_speech) == '1'
	end
	
	def speak(kind, amount=0)
		case kind
		when :pass
		  setVoiceTo :speech_voice_tests_pass
			speechSynthesizer.startSpeakingString(Defaults.get(:speech_phrase_tests_pass).sub(/\?/, amount.to_s))
		when :failed
		  setVoiceTo :speech_voice_tests_fail
			speechSynthesizer.startSpeakingString(Defaults.get(:speech_phrase_tests_fail).sub(/\?/, amount.to_s))
		when :pending
		  setVoiceTo :speech_voice_tests_pending
			speechSynthesizer.startSpeakingString(Defaults.get(:speech_phrase_tests_pending).sub(/\?/, amount.to_s))
		when :error
		  setVoiceTo :speech_voice_tests_fail
			speechSynthesizer.startSpeakingString('SpecRunner aborted. Please have a look at the output for more information.')
		end
	end
	
	def setVoiceTo(key)
	  if Defaults.get(key).empty?
	    @speechSynthesizer.setVoice(OSX::NSSpeechSynthesizer.defaultVoice)
	  else
		  @speechSynthesizer.setVoice("com.apple.speech.synthesis.voice." + Defaults.get(key))
		end
  end
end