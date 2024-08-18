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

        .accordion {
            background-color: #4CAF50;
            color: white;
            cursor: pointer;
            padding: 18px;
            width: 100%;
            text-align: left;
            border: none;
            outline: none;
            transition: 0.4s;
            font-size: 18px;
            border-radius: 4px;
            margin-top: 10px;
        }

        .accordion.active, .accordion:hover {
            background-color: #45a049;
        }

        .panel {
            padding: 0 18px;
            display: none;
            background-color: white;
            overflow: hidden;
            margin-top: 5px;
        }

        .down-arrow-icon::after {
            content: "\25BC"; /* Unicode character for down arrow */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .up-arrow-icon::after {
            content: "\25B2"; /* Unicode character for up arrow */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .double-up-icon::after {
            content: "\23EB"; /* Unicode character for double up arrow */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .double-down-icon::after {
            content: "\23EC"; /* Unicode character for double down arrow */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .lock-open-icon::after {
            content: "\1F513"; /* Unicode character for open lock */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .lock-closed-icon::after {
            content: "\1F512"; /* Unicode character for closed lock */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-left: 5px; /* Adjust spacing as needed */
        }

        .stop-icon::before {
            content: "\1F6D1"; /* Unicode character for stop icon */
            font-size: 20px; /* Adjust size as needed */
            display: inline-block;
            margin-right: 5px; /* Adjust spacing as needed */
        }

        .settings-icon::before {
            content: "\2699"; /* Unicode character for gear icon */
            font-size: 18px; /* Adjust size as needed */
            display: inline-block;
            margin-right: 10px; /* Adjust spacing as needed */
        }

    </style>
</head>
<body>
    <h1 class="panel-title">PANEL MOVEMENT</h1>
    <h2 id="messageHeader">%message%</h2>
    <br/>
    <a href="/full_up" class="button"><span>Full-up <span class="double-up-icon"></span></span></a>
    <br/>
    <a href="/full_down" class="button"><span>Full-down <span class="double-down-icon"></span></span></a>
    <br/>
    <a href="/stop" class="button"><span>Stop <span class="stop-icon"></span></span></a>
    <br/>
    <a href="#" class="button" onclick="moveToM1()"><span>GO M1 <span id="m1_value"></span> mm</span></a>
    <br/>
    <a href="#" class="button" onclick="moveToM2()"><span>GO M2 <span id="m2_value"></span> mm</span></a>
    <br/>
    <a href="#" class="button" onclick="toggleDisplayLock()"><span id="is_display_locked">UNLOCKED <span class="lock-open-icon"></span></span></a>
    <br/>

    <!-- Accordion Section -->
    <button class="accordion"><span class="settings-icon"></span>Advanced Controls</button>
    <div class="panel">
        <a href="/up" class="button"><span>Little Up <span class="up-arrow-icon"></span></span></a>
        <br/>
        <a href="/down" class="button"><span>Little Down <span class="down-arrow-icon"></span></span></a>
        <br/>
        <input type="text" id="targetPosition" placeholder="Target position (mm)">
        <a href="#" class="button" onclick="moveToTarget()"><span>Go to Target</span></a>
    </div>

    <script>
        var accordionElements = document.getElementsByClassName("accordion");

        for (var accordionIndex = 0; accordionIndex < accordionElements.length; accordionIndex++) {
            accordionElements[accordionIndex].addEventListener("click", function() {
                this.classList.toggle("active");
                var panel = this.nextElementSibling;
                if (panel.style.display === "block") {
                    panel.style.display = "none";
                } else {
                    panel.style.display = "block";
                }
            });
        }

        function toggleDisplayLock() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/toggle_lock', true);
            xhr.onreadystatechange = function () {
                loadStateValues();
            };
            xhr.send();
        }
        function moveToM1() {
            doMoveToTarget(document.getElementById('m1_value').innerText);
        }
        function moveToM2() {
            doMoveToTarget(document.getElementById('m2_value').innerText);
        }
        function loadStateValues() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '/status', true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var jsonResponse = JSON.parse(xhr.responseText);
                        document.getElementById('m1_value').innerText = jsonResponse.memory_m1_mm;
                        document.getElementById('m2_value').innerText = jsonResponse.memory_m2_mm;
                        var displayElement = document.getElementById('is_display_locked');
                        if (jsonResponse.is_display_locked) {
                            displayElement.classList.add('lock-closed-icon');
                            displayElement.classList.remove('lock-open-icon');
                            displayElement.innerText = 'UNLOCK';
                        } else {
                            displayElement.classList.add('lock-open-icon');
                            displayElement.classList.remove('lock-closed-icon');
                            displayElement.innerText = 'LOCK';
                        }
                    } else {
                        console.error('Request failed with status:', xhr.status);
                    }
                }
            };
            xhr.send();
        }
        loadStateValues();
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
                window.location.href = "/panel";
            }
        }, 1000);
    </script>
</body>
</html>
)=====";

#endif // HTML_PANEL_H
