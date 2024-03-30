#ifndef HTML_PANEL_H
#define HTML_PANEL_H

const char* HTML_PANEL = R"=====(
<!DOCTYPE html>
<html>
<head>
    <title>HAFELE STANDING PANEL</title>
    <style>
    /* Style for link as button */
    a.button, input[type="text"] {
        display: block;
        margin-bottom: 10px; /* Add margin between buttons and input */
        padding: 15px 30px; /* Increase padding for larger buttons */
        text-decoration: none;
        background-color: #4CAF50; /* Green */
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        text-align: center;
        font-size: 16px; /* Default font size */
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
            padding: 20px 40px; /* Increase padding further for smaller screens */
            font-size: 18px; /* Increase font size for smaller screens */
        }
    }
    </style>
</head>
<body>
    <h1>PANEL MOVEMENT</h1>
    <br/>
    <a href="/full_up" class="button">Full-up</a>
    <br/>
    <a href="/full_down" class="button">Full-down</a>
    <br/>
    <a href="/up" class="button">Up 1 sec.</a>
    <br/>
    <a href="/down" class="button">Down 1 sec.</a>
    <br/>
    <input type="text" id="targetPosition" placeholder="Enter position in mm">
    <a href="#" class="button" onclick="moveToTarget()">Move to target position</a>
    <br/>
    <script>
        function moveToTarget() {
            var targetParam = document.getElementById("targetPosition").value;
            var newUrl = "/move_to?target=" + targetParam;
            window.location.href = newUrl;
        }
    </script>
</body>
</html>
)=====";

#endif // HTML_PANEL_H
