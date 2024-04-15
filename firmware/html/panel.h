#ifndef HTML_PANEL_H
#define HTML_PANEL_H

const char* HTML_PANEL = R"=====(
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HAFELE STANDING PANEL</title>
    <style>
        /* Style for link as button */
        a.button, input[type="text"] {
            display: block;
            margin-bottom: 5px; /* Add margin between buttons and input */
            padding: 10px 25px; /* Increase padding for larger buttons */
            text-decoration: none;
            background-color: #4CAF50; /* Green */
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-align: center;
            font-size: 16px; /* Default font size */
        }

        input[type="text"] {
            width: 100%;
        }

        /* Hover effect */
        a.button:hover, input[type="text"]:hover {
            background-color: #45a049; /* Darker green */
        }

        /* Active effect */
        a.button:active, input[type="text"]:active {
            background-color: #3e8e41; /* Dark green */
        }

        /* Media query for smaller screens */
        @media screen and (max-width: 600px) {
            a.button, input[type="text"] {
                padding: 15px 35px; /* Increase padding further for smaller screens */
                font-size: 25px; /* Increase font size for smaller screens */
            }
            .panel-title {
                display: none;
            }
        }

       .down-arrow::after {
           content: "\25BC"; /* Unicode character for down arrow */
           font-size: 20px; /* Adjust size as needed */
           display: inline-block;
           margin-left: 5px; /* Adjust spacing as needed */
       }

       .up-arrow::after {
           content: "\25B2"; /* Unicode character for down arrow */
           font-size: 20px; /* Adjust size as needed */
           display: inline-block;
           margin-left: 5px; /* Adjust spacing as needed */
       }

       .double-up-arrow::after {
           content: "\23EB"; /* Unicode character for down arrow */
           font-size: 20px; /* Adjust size as needed */
           display: inline-block;
           margin-left: 5px; /* Adjust spacing as needed */
       }

       .double-down-arrow::after {
           content: "\23EC"; /* Unicode character for down arrow */
           font-size: 20px; /* Adjust size as needed */
           display: inline-block;
           margin-left: 5px; /* Adjust spacing as needed */
       }
    </style>
</head>
<body>
    <h1 class="panel-title">PANEL MOVEMENT</h1>
    <h2 id="messageHeader">%message%</h2>
    <br/>
    <a href="/full_up" class="button"><span>Full-up <span class="double-up-arrow"></span></span></a>
    <br/>
    <a href="/full_down" class="button">Full-down <span class="double-down-arrow"></span></a>
    <br/>
    <a href="/up" class="button">Little Up <span class="up-arrow"></span></a>
    <br/>
    <a href="/down" class="button">Little Down <span class="down-arrow"></span></a>
    <br/>
    <input type="text" id="targetPosition" placeholder="Target position (mm)">
    <a href="#" class="button" onclick="moveToTarget()">Go target position</a>
    <br/>
    <a href="#" class="button" onclick="moveToM1()">GO M1 <span id="m1_value"> mm</span></a>
    <br/>
    <a href="#" class="button" onclick="moveToM2()">GO M2 <span id="m2_value"> mm</span></a>
    <br/>
    <script>
        function moveToM1() {
            doMoveToTarget(document.getElementById('m1_value').innerHTML);
        }
        function moveToM2() {
            doMoveToTarget(document.getElementById('m2_value').innerHTML);
        }
        function loadMemoriesValues() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/status', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var jsonResponse = JSON.parse(xhr.responseText);
                        document.getElementById('m1_value').innerHTML = jsonResponse.memory_m1_mm;
                        document.getElementById('m2_value').innerHTML = jsonResponse.memory_m2_mm;
                    } else {
                        console.error('Request failed with status:', xhr.status);
                    }
                }
            };
            xhr.send();
        }
        loadMemoriesValues();
        function moveToTarget() {
            doMoveToTarget(document.getElementById("targetPosition").value)
        }
        function doMoveToTarget(target) {
            var newUrl = "/move_to?target=" + target;
            window.location.href = newUrl;
        }
        setTimeout(function () {
            document.getElementById("messageHeader").style.display = "none";
            if (window.location.pathname !== "/panel") {
                // window.location.href = "/panel";
            }
        }, 1000);
    </script>
</body>
</html>
)=====";

#endif // HTML_PANEL_H
