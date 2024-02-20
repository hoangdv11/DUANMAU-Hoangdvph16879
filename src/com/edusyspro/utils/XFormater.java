/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.utils;

import java.text.NumberFormat;
import java.util.Currency;
import java.util.Locale;
import javax.swing.JTextField;

/**
 *
 * @author DaiAustinYersin
 */
public class XFormater {

    public static String toCurrency(double currencyAmount) {
        // Create a new Locale
        Locale usa = new Locale("en", "US");
        // Create a Currency instance for the Locale
        Currency dollars = Currency.getInstance(usa);
        // Create a formatter given the Locale
        NumberFormat dollarFormat = NumberFormat.getCurrencyInstance(usa);

        // Format the Number into a Currency String
//        return dollars.getDisplayName() + ": " + dollarFormat.format(currencyAmount);
        return dollarFormat.format(currencyAmount);
    }

    public static double toDouble(JTextField currencyAmount) {
        double result = 0;
        if (!currencyAmount.getText().isEmpty()) {
            if (currencyAmount.getText().contains(",") && !currencyAmount.getText().startsWith("$")) {
                int comma = currencyAmount.getText().indexOf(",");
                result = Double.parseDouble(currencyAmount.getText().substring(0, comma) + currencyAmount.getText().substring(comma + 1));
            } else if (!currencyAmount.getText().contains(",") && currencyAmount.getText().startsWith("$")) {
                result = Double.parseDouble(currencyAmount.getText().substring(1));
            } else if (currencyAmount.getText().contains(",") && currencyAmount.getText().startsWith("$")) {
                int comma = currencyAmount.getText().indexOf(",");
                result = Double.parseDouble(currencyAmount.getText().substring(1, comma) + currencyAmount.getText().substring(comma + 1));
            } else {
                result = Double.parseDouble(currencyAmount.getText());
            }
        }
        return result;
    }
}
