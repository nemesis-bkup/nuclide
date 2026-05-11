/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

typedef enum
{
    CALCULATOR_NONE,
    CALCULATOR_ADDITION,
    CALCULATOR_SUBTRACTION,
    CALCULATOR_MULTIPLICATION,
    CALCULATOR_DIVISION
} calcualtorModes_t;

class
vguiTool_Calculator:vguiApplication
{
    void vguiTool_Calculator(void);

    virtual void Launched(void);

    nonvirtual void Calculator_Digit(vguiControl);
    nonvirtual void Calculator_Operation(vguiControl);

private:

    vguiTextBox display;
    vguiButton buttons[18];
    bool editing;
    bool decimalSeparator;
    bool enteredDecimalSeparator;
    float enteredNumber;
    float fractionalDigits;
    float enteredfractionalDigits;
    float operation;
    float result;
};

void
vguiTool_Calculator::vguiTool_Calculator(void)
{
    editing = false;
    decimalSeparator = false;
    enteredDecimalSeparator = false;
    enteredNumber = 0;
    fractionalDigits = 0;
    enteredfractionalDigits = 0;
    operation = 0;
    result = 0;
}

void
vguiTool_Calculator::Calculator_SetDisplay(float aNumber, float displayDecimalSeparator, float fractionalDigits)
{
    if (displayDecimalSeparator) {
        display.SetText(sprintf("%#.*f", fractionalDigits, aNumber));
    } else {
        display.SetText(sprintf("%.0f", aNumber));
    }
}

void
vguiTool_Calculator::Calculator_Error()
{
    display.SetText("ERROR");
}

void
vguiTool_Calculator::Calculator_Clear(vguiControl sender)
{
    decimalSeparator = false;
    editing = true;
    enteredDecimalSeparator = false;
    enteredNumber = 0;
    enteredfractionalDigits = 0;
    fractionalDigits = 0;
    operation = CALCULATOR_NONE;
    result = 0;

    Calculator_SetDisplay(0, false, 0);
}

void
vguiTool_Calculator::Calculator_Equal(vguiControl sender)
{
    switch (operation) {
    case CALCULATOR_NONE:
        enteredNumber = 0;
        enteredDecimalSeparator = false;
        enteredfractionalDigits = 0;
        break;
    case CALCULATOR_ADDITION:
        result = result + enteredNumber;
        break;
    case CALCULATOR_SUBTRACTION:
        result = result - enteredNumber;
        break;
    case CALCULATOR_MULTIPLICATION:
        result = result * enteredNumber;
        break;
    case CALCULATOR_DIVISION:
        if (enteredNumber == 0) {
            Calculator_Error();
            return;
        } else {
            result = result / enteredNumber;
        }
        break;
    }

    if (enteredfractionalDigits > fractionalDigits) {
        fractionalDigits = enteredfractionalDigits;
    }

    if (result != ceil(result)) {
        decimalSeparator = 1;
        fractionalDigits = 7;
    }

    Calculator_SetDisplay(result, decimalSeparator, fractionalDigits);
    enteredNumber = result;
    enteredfractionalDigits = fractionalDigits;
    enteredDecimalSeparator = decimalSeparator;
    operation = CALCULATOR_NONE;
    editing = false;
}

void
vguiTool_Calculator::Calculator_Digit(vguiControl sender)
{
    float currentDigit = sender.GetTag();

    if (editing == false) {
        enteredNumber = 0;
        enteredDecimalSeparator = false;
        enteredfractionalDigits = 0;
        editing = true;
    }

    if (enteredDecimalSeparator) {
        enteredNumber = enteredNumber + (currentDigit * pow (0.1, 1 + enteredfractionalDigits));
        enteredfractionalDigits++;
    } else  {
        enteredNumber = enteredNumber * 10 + (currentDigit);

        if (enteredNumber > pow (10, 15)) {
            Calculator_Error();
            return;
        }
    }

    Calculator_SetDisplay(enteredNumber, enteredDecimalSeparator, enteredfractionalDigits);
}

void
vguiTool_Calculator::Calculator_DecimalSeparator(vguiControl sender)
{
    if (!editing) {
        enteredNumber = 0;
        enteredDecimalSeparator = false;
        enteredfractionalDigits = 0;
        editing = true;
    }

    if (!enteredDecimalSeparator) {
        enteredDecimalSeparator = true;
        Calculator_SetDisplay(enteredNumber, enteredDecimalSeparator, 0);
    }
}
void
vguiTool_Calculator::Calculator_Operation(vguiControl sender)
{
    float a = sender.GetTag();

    if (operation == CALCULATOR_NONE) {
        result = enteredNumber;
        enteredNumber = 0;
        decimalSeparator = false;
        enteredfractionalDigits = 0;
        operation = a;
    } else {
        Calculator_Equal(sender);
        Calculator_Operation(sender);
    }
}

void
vguiTool_Calculator::Calculator_SquareRoot(vguiControl sender)
{
    if (operation == CALCULATOR_NONE) {
        result = sqrt (enteredNumber);
        Calculator_SetDisplay(result, (ceil(result) != result), 7);
        enteredNumber = result;
        editing = false;
    } else {
        Calculator_Equal(sender);
        Calculator_SquareRoot(sender);
    }
}

void
vguiTool_Calculator::Launched(void)
{
    super::Launched();

    SetSize( [106,169] );

    display = spawn(vguiTextBox);
    display.SetPos([8,27]);
    display.SetSize([86,20]);

    buttons[0] = vguiButton::InitWithFrame([9, 140], [40, 16]);
    buttons[0].SetTitle("0");
    buttons[0].SetTag(0);
    buttons[0].SetAction(Calculator_Digit);
    buttons[0].SetKeyEquivalent("0");

    buttons[1] = vguiButton::InitWithFrame([9, 118], [18, 16]);
    buttons[1].SetTitle("1");
    buttons[1].SetTag(1);
    buttons[1].SetAction(Calculator_Digit);
    buttons[1].SetKeyEquivalent("1");

    buttons[2] = vguiButton::InitWithFrame([31, 118], [18, 16]);
    buttons[2].SetTitle("2");
    buttons[2].SetTag(2);
    buttons[2].SetAction(Calculator_Digit);
    buttons[2].SetKeyEquivalent("2");

    buttons[3] = vguiButton::InitWithFrame([53, 118], [18, 16]);
    buttons[3].SetTitle("3");
    buttons[3].SetTag(3);
    buttons[3].SetAction(Calculator_Digit);
    buttons[3].SetKeyEquivalent("3");

    buttons[4] = vguiButton::InitWithFrame([9, 96], [18, 16]);
    buttons[4].SetTitle("4");
    buttons[4].SetTag(4);
    buttons[4].SetAction(Calculator_Digit);
    buttons[4].SetKeyEquivalent("4");

    buttons[5] = vguiButton::InitWithFrame([31, 96], [18, 16]);
    buttons[5].SetTitle("5");
    buttons[5].SetTag(5);
    buttons[5].SetAction(Calculator_Digit);
    buttons[5].SetKeyEquivalent("5");

    buttons[6] = vguiButton::InitWithFrame([53, 96], [18, 16]);
    buttons[6].SetTitle("6");
    buttons[6].SetTag(6);
    buttons[6].SetAction(Calculator_Digit);
    buttons[6].SetKeyEquivalent("6");

    buttons[7] = vguiButton::InitWithFrame([9, 74], [18, 16]);
    buttons[7].SetTitle("7");
    buttons[7].SetTag(7);
    buttons[7].SetAction(Calculator_Digit);
    buttons[7].SetKeyEquivalent("7");

    buttons[8] = vguiButton::InitWithFrame([31, 74], [18, 16]);
    buttons[8].SetTitle("8");
    buttons[8].SetTag(8);
    buttons[8].SetAction(Calculator_Digit);
    buttons[8].SetKeyEquivalent("8");

    buttons[9] = vguiButton::InitWithFrame([53, 74], [18, 16]);
    buttons[9].SetTitle("9");
    buttons[9].SetTag(9);
    buttons[9].SetAction(Calculator_Digit);
    buttons[9].SetKeyEquivalent("9");

    buttons[10] = vguiButton::InitWithFrame([53, 140], [18, 16]);
    buttons[10].SetTitle(".");
    buttons[10].SetAction(Calculator_DecimalSeparator);
    buttons[10].SetKeyEquivalent(".");

    buttons[11] = vguiButton::InitWithFrame([31, 52], [18, 16]);
    buttons[11].SetTitle("SQR");
    buttons[11].SetAction(Calculator_SquareRoot);
    buttons[11].SetKeyEquivalent("s");

    buttons[12] = vguiButton::InitWithFrame([75, 118], [18, 38]);
    buttons[12].SetTitle("+");
    buttons[12].SetTag(CALCULATOR_ADDITION);
    buttons[12].SetAction(Calculator_Operation);
    buttons[12].SetKeyEquivalent("+");

    buttons[13] = vguiButton::InitWithFrame([75, 96], [18, 16]);
    buttons[13].SetTitle("-");
    buttons[13].SetTag(CALCULATOR_SUBTRACTION);
    buttons[13].SetAction(Calculator_Operation);
    buttons[13].SetKeyEquivalent("-");

    buttons[14] = vguiButton::InitWithFrame([75, 52], [18, 16]);
    buttons[14].SetTitle("*");
    buttons[14].SetTag(CALCULATOR_MULTIPLICATION);
    buttons[14].SetAction(Calculator_Operation);
    buttons[14].SetKeyEquivalent("*");

    buttons[15] = vguiButton::InitWithFrame([75,74], [18, 16]);
    buttons[15].SetTitle("/");
    buttons[15].SetTag(CALCULATOR_DIVISION);
    buttons[15].SetAction(Calculator_Operation);
    buttons[15].SetKeyEquivalent("/");

    buttons[16] = vguiButton::InitWithFrame([9, 52], [18, 16]);
    buttons[16].SetTitle("CL");
    buttons[16].SetAction(Calculator_Clear);
    buttons[16].SetKeyEquivalent("C");

    buttons[17] = vguiButton::InitWithFrame([53, 52], [18, 16]);
    buttons[17].SetTitle("=");
    buttons[17].SetAction(Calculator_Equal);
    buttons[17].SetKeyEquivalent("=");

    for (int i = 0; i < 18; i++)
        Add(buttons[i]);

    Add( display );
}
