// Get all the keys from document
var keys = document.querySelectorAll('#bomb span');
var operators = ['+', '-', 'x', '÷'];
var decimalAdded = false;

// Add onclick event to all the keys and perform operations
for(var i = 0; i < keys.length; i++) {
  keys[i].onclick = function(e) {
    // Get the input and button values
    var input = document.querySelector('.screen');
    var inputVal = input.innerHTML;
    var btnVal = this.innerHTML;

    // Now, just append the key values (btnValue) to the input string and finally use javascript's eval function to get the result
    // If clear key is pressed, erase everything
    if(btnVal == 'C') {
      input.innerHTML = '';
      decimalAdded = false;
    }

    // If eval key is pressed, calculate and display the result
    else if(btnVal == '=') {
      var equation = inputVal;
      var lastChar = equation[equation.length - 1];

      // Replace all instances of x and ÷ with * and / respectively. This can be done easily using regex and the 'g' tag which will replace all instances of the matched character/substring
      equation = equation.replace(/x/g, '*').replace(/÷/g, '/');

      // Final thing left to do is checking the last character of the equation. If it's an operator or a decimal, remove it
      if(operators.indexOf(lastChar) > -1 || lastChar == '.')
        equation = equation.replace(/.$/, '');

      if(equation)
        input.innerHTML = eval(equation);

      decimalAdded = false;
    }

    // Basic functionality of the calculator is complete. But there are some problems like
    // 1. No two operators should be added consecutively.
    // 2. The equation shouldn't start from an operator except minus
    // 3. not more than 1 decimal should be there in a number

    // We'll fix these issues using some simple checks

    // indexOf works only in IE9+
    else if(operators.indexOf(btnVal) > -1) {
      // Operator is clicked
      // Get the last character from the equation
      var lastChar = inputVal[inputVal.length - 1];

      // Only add operator if input is not empty and there is no operator at the last
      if(inputVal != '' && operators.indexOf(lastChar) == -1)
        input.innerHTML += btnVal;

      // Allow minus if the string is empty
      else if(inputVal == '' && btnVal == '-')
        input.innerHTML += btnVal;

      // Replace the last operator (if exists) with the newly pressed operator
      if(operators.indexOf(lastChar) > -1 && inputVal.length > 1) {
        // Here, '.' matches any character while $ denotes the end of string, so anything (will be an operator in this case) at the end of string will get replaced by new operator
        input.innerHTML = inputVal.replace(/.$/, btnVal);
      }

      decimalAdded =false;
    }

    // Now only the decimal problem is left. We can solve it easily using a flag 'decimalAdded' which we'll set once the decimal is added and prevent more decimals to be added once it's set. It will be reset when an operator, eval or clear key is pressed.
    else if(btnVal == '.') {
      if(!decimalAdded) {
        input.innerHTML += btnVal;
        decimalAdded = true;
      }
    }

    // if any other key is pressed, just append it
    else {
      input.innerHTML += btnVal;
    }

    // prevent page jumps
    e.preventDefault();
  }
}

$(document).ready( function() {

      $(".wire_btn").click(function(){
        var btn_color = this.id.split("_")[0];
        var datalist = { color: btn_color, bomb_id: $("#bomb_id").val() };
        $.ajax({
          type: "POST",
          url: "http://localhost:9292/bomb/diffuse",
          data: JSON.stringify(datalist),
          dataType: "json",
          success: function(returnObject)
          {
          }
        });
      })

      var keys = document.querySelectorAll('#bomb span');
      for(var i = 0; i < keys.length; i++) {
        keys[i].onclick = function(e) {
          var input = document.querySelector('.screen');
          var inputVal = input.innerHTML;
          var btnVal = this.innerHTML;
          if(btnVal == 'Activate'){
          $( "#dialog-confirm" ).dialog({
              resizable: false,
              height:200,
              modal: true,
              buttons: {
                "Activate bomb?": function() {
                  evaluateCode(input.innerHTML, btnVal, $("#bomb_id").val());
                  $( this ).dialog( "close" );
                },
                Cancel: function() {
                  $( this ).dialog( "close" );
                }
              }
            });
          }
          else if((btnVal == 'Submit') || (btnVal == 'Deactivate'))  {
            evaluateCode(input.innerHTML, btnVal, $("#bomb_id").val());
          }
          else if (btnVal == 'Configure')
          {
            configureBomb();
          }
          else if(btnVal == 'C') {
            input.innerHTML = '';
          }
          else {
            input.innerHTML += btnVal;
          }
        }
      }
      var start = 0;
      var refreshId = window.setInterval(function(){
        $.ajax({
          type: "GET",
          url: "http://localhost:9292/bomb/"+$("#bomb_id").val(),
          dataType: "json",
          success: function(returnObject)
          {
            if(returnObject.status == "active")
            {
              $('.timer').css("display", "block");
              $(".bomb_wires").css("display", "block");
              $("#bomb_status").removeClass("bomb_inactive");
              $("#bomb_status").removeClass("bomb_explode");
              $("#bomb_status").addClass("bomb_active");
              $("#bomb_status").val("Active");
              $('.timer').html(((returnObject.detonation_time) - start) + " Seconds ");
              var html = ""
              var str = ""
              var btn_str = ""


              start += 1
            }
            else if(returnObject.status == "inactive")
            {
              $("#bomb_status").removeClass("bomb_active");
              $("#bomb_status").removeClass("bomb_explode");
              $("#bomb_status").addClass("bomb_inactive");
              $("#bomb_status").val("Inactive");
            }
            else
            {
              $("#bomb_status").removeClass("bomb_active");
              $("#bomb_status").removeClass("bomb_inactive");
              $("#bomb_status").addClass("bomb_explode");
              $("#bomb_status").val("Exploded");
              start += 1
            }
          },
          error: function (xhr){
            if(xhr.status == 0)
            {
              clearInterval(refreshId);
            }
            }
        });
      }, 1000);


    function evaluateCode(code, btnvalue, bombid)
    {
      var action = btnvalue.toLowerCase();
      var datalist = {}
      if(action == "activate"){
        datalist = {activation_code: code, bomb_id: bombid}
      }
      else
      {
        datalist = {deactivation_code: code, bomb_id: bombid}
      }

      $.ajax({
        type: "POST",
        url: " http://localhost:9292/bomb/"+action,
        dataType: "json",
        data: JSON.stringify(datalist),
        success: function(returnObject)
        {

          if(returnObject.status == "active")
          {
            $("#bomb_status").removeClass("bomb_inactive");
            $("#bomb_status").addClass("bomb_active");
            $("#bomb_status").val("Active");
          }
        },
        error: function (xhr){  alert( 'xhr = '+xhr.status ); }
      });
    }
});