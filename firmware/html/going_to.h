#ifndef HTML_GOING_TO_H
#define HTML_GOING_TO_H

const char* HTML_GOING_TO = R"=====(
<!DOCTYPE html>
<html>
<head>
    <title>HAFELE STANDING PANEL - MOVING</title>
</head>
<body>
    <p>Ok, going %s and wait 1 sec. for redirect...</p>
    <script>
        setTimeout(function() {
            window.location.href = "/panel";
        }, 1000);
    </script>
</body>
</html>
)=====";

#endif // HTML_GOING_TO_H
