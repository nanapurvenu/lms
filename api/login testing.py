from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Make sure you have webdriver_manager installed for automatic driver management
# from selenium.webdriver.firefox.service import Service
# from webdriver_manager.firefox import GeckoDriverManager

try:
    # Initialize Firefox browser (assuming GeckoDriver is set up)
    # If using webdriver_manager:
    # service = Service(GeckoDriverManager().install())
    # driver = webdriver.Firefox(service=service)
    # If not using webdriver_manager, just:
    driver = webdriver.Firefox()

    login_url = "https://www.saucedemo.com/"
    driver.get(login_url)
    driver.maximize_window()

    username = "standard_user"
    password = "secret_sauce"

    # Initialize WebDriverWait to wait up to 10 seconds for elements
    wait = WebDriverWait(driver, 10)

    print("Attempting to find username and password fields...")

    # CORRECTED: Use 'user-name' for the username field ID
    username_field = wait.until(EC.visibility_of_element_located((By.ID, "user-name")))
    password_field = wait.until(EC.visibility_of_element_located((By.ID, "password")))

    username_field.send_keys(username)
    password_field.send_keys(password)
    print("Username and password entered.")

    print("Attempting to find and click login button...")
    login_button = wait.until(EC.element_to_be_clickable((By.ID, "login-button")))

    # This assertion is good for checking button state
    assert not login_button.get_attribute("disabled")

    login_button.click()
    print("Login button clicked.")

    # REMINDER for successful login check:
    # Your current success assertion: assert success_element.text == "products"
    # This is problematic for two reasons:
    # 1. To get the page title, use driver.title, not .text on a By.CSS_SELECTOR("title") element.
    # 2. The actual title of the products page on saucedemo.com is "Swag Labs", not "products".
    #
    # A more robust check for successful login would be:
    print("Verifying successful login by page title...")
    wait.until(EC.title_contains("Swag Labs"))  # Wait for the title to contain "Swag Labs"
    assert driver.title == "Swag Labs"
    print(f"Login successful! Current page title: '{driver.title}'")

    # Or check for a distinct element on the products page, e.g., the "Products" heading
    # products_heading = wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, ".title")))
    # assert products_heading.text == "Products"
    # print(f"Products heading found: '{products_heading.text}'")

    print("Test passed successfully!")

except TimeoutException:
    print("Error: Element not found or not ready within the specified time. Check locators or page loading.")
except NoSuchElementException as e:
    print(f"Error: Element not found: {e}. Double-check your locators.")
except AssertionError as e:
    print(f"Assertion failed: {e}. Test failed.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

finally:
    if 'driver' in locals() and driver:  # Ensure driver exists before trying to quit
        driver.quit()
        print("Browser closed.")