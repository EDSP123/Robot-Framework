*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Archive
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Tables


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website

    ${orders}=    Set Variable
    ${orders}=    Get orders

    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds    10x    0.5s    Fill the form    ${row}
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Click Button    order-another
    END

    Create ZIP package from PDF files


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    browser_selection=chrome

Download the file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get orders
    ${orders}=    Set Variable

    Download the file
    ${orders}=    Read table from CSV    orders.csv    header=${True}
    RETURN    ${orders}

Close the annoying modal
    Click Button    css:.btn.btn-dark

Fill the form
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath: /html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    preview
    Click Button    order
    Wait Until Element Is Visible    receipt

Take a screenshot of the robot
    [Arguments]    ${orderNumber}

    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}robot_${orderNumber}.png
    RETURN    ${OUTPUT_DIR}${/}receipts${/}robot_${orderNumber}.png

Store the receipt as a PDF file
    [Arguments]    ${orderNumber}
    Wait Until Element Is Visible    id:receipt
    ${order_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_html}    ${OUTPUT_DIR}${/}receipts${/}order_${orderNumber}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts${/}order_${orderNumber}.pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}

    ${files}=    Create List    ${screenshot}    ${pdf}

    Add Files To Pdf    ${files}    ${pdf}

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file_name}
