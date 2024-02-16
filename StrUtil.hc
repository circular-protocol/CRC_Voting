/******************************************************************************************
*
*         Circular Protocol
*         String Utilities and helper functions 
*         January 2024
*
*******************************************************************************************/

/**
 * 
 * converts a string to its hexadecimal representation
 * 
 *  input : string to convert in Hex 
 *  
 */
 
function stringToHex(input) {
    var hex = '';
    for (var i = 0; i < input.length; i++) {
        var currentHex = input.charCodeAt(i).toString(16);
        if (currentHex.length < 2) {
            currentHex = '0' + currentHex;
        }
        hex += currentHex;
    }
    return hex;
}


/**
 * 
 *  converts a hexadecimal string to a regular string
 * 
 *  hex : Hex string to convert 
 *  
 */
function hexToString(hex) {
    var string = '';
    if (hex.startsWith('0x')) {hex = hex.slice(2);}
    for (var i = 0; i < hex.length; i += 2) {
        string += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
    }
    return string;
}


/**
 * 
 *  converts a string to its base64 representation
 * 
 *  input : string to convert 
 *  
 */
function stringToBase64(input) {
    const base64 = btoa(input);
    return base64;
}

/**
 * 
 *  converts a base64 string to a regular string
 * 
 *  base64 : string to convert 
 *  
 */
function base64ToString(base64) {
    const string = atob(base64);
    return string;
}
