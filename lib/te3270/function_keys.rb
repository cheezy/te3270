
module TE3270
  #
  # Creates methods that are mixed in with the +TE3270+ module that represent all of the
  # function keys that can be send to the system.  These keys would typically be sent to
  # the +send_keys_ method.
  #
  # @example Using a function key
  #   on(MyScreen).send_keys TE3270.Enter
  #
  module FunctionKeys

    KEYS = [
        'Attn',
        'BackSpace',
        'BackTab',
        'CapsLock',
        'Clear',
        'Down',
        'Left',
        'Left2',
        'Right',
        'Right2',
        'CursorSelect',
        'Up',
        'Delete',
        'Dup',
        'Enter',
        'EraseEOF',
        'EraseInput',
        'FieldMark',
        'Home',
        'Insert',
        'BackTab',
        'NewLIne',
        'PenSel',
        'Print',
        'Reset',
        'ShiftOn',
        'SysReq',
        'Tab',
        'Pa1',
        'Pa2',
        'Pa3',
        'Pf1',
        'Pf2',
        'Pf3',
        'Pf4',
        'Pf5',
        'Pf6',
        'Pf7',
        'Pf8',
        'Pf9',
        'Pf10',
        'Pf11',
        'Pf12',
        'Pf13',
        'Pf14',
        'Pf15',
        'Pf16',
        'Pf17',
        'Pf18',
        'Pf19',
        'Pf20',
        'Pf21',
        'Pf22',
        'Pf23',
        'Pf24',
    ]

    KEYS.each do |key|
      define_method(key) do
        "<#{key}>"
      end
    end

  end
end
