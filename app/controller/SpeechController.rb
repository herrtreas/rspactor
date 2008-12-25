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
		
		init_phrases_and_voices
		@speechSynthesizer = NSSpeechSynthesizer.alloc.initWithVoice(@voiceForError)
	end
	
	def specRunFinishedSingleSpec(notification)    
    return unless speak_results?
		
    spec = notification.userInfo.first
		speak(spec.state)
  end
  
  def specRunFinishedWithSummaryDump(notification)    
    return unless speak_results?

    duration, example_count, failure_count, pending_count = notification.userInfo
		#message = "#{example_count} examples, #{failure_count} failed, #{pending_count} pending. Took #{("%0.2f" % duration).to_f} seconds"
		
		if failure_count.to_i > 0
			speak(:failed, failure_count)
		elsif pending_count.to_i > 0
			speak(:pending, pending_count)
		else
			speak(:pass)
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
	
	def init_phrases_and_voices
		@phraseForPassed = $app.default_from_key(:speech_phrase_tests_pass)
		@phraseForFailed = $app.default_from_key(:speech_phrase_tests_fail)
		@phraseForPending = $app.default_from_key(:speech_phrase_tests_pending)
		
		@voiceForPassed = $app.default_from_key(:speech_voice_tests_pass)
		@voiceForFailed = $app.default_from_key(:speech_voice_tests_fail)
		@voiceForPending = $app.default_from_key(:speech_voice_tests_pending)
		@voiceForError = @voiceForFailed
	end
	
	def speak(kind, amount=0)
		case kind
		when :pass
			@speechSynthesizer.setVoice(@voiceForPassed)
			speechSynthesizer.startSpeakingString(@phraseForPassed)
		when :failed
			@speechSynthesizer.setVoice(@voiceForFailed)
			speechSynthesizer.startSpeakingString(@phraseForFailed)
		when :pending
			@speechSynthesizer.setVoice(@voiceForPending)
			speechSynthesizer.startSpeakingString(@phraseForPending)
		when :error
			@speechSynthesizer.setVoice(@voiceForError)
			speechSynthesizer.startSpeakingString('SpecRunner aborted. Please have a look at the output for more information.')
		end
	end
end