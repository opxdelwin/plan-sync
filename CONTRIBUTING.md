# Contributing to Plan Sync

We appreciate your interest in contributing to Plan Sync and helping to make it even better! As a student-contributed timetable app, we rely on your input to ensure accurate and up-to-date class schedules. Here's how you can contribute:

## Contribution Process

1. **Download the JSON Template**: To contribute your class timetable, copy and modify below attached JSON template and fill out.

2. **Fill Out the JSON Template**: Open the JSON template and carefully fill in the details of your class schedule. Ensure that you follow the provided format and guidelines for accuracy.

   ***Alternatively***, you can use https://jsoneditoronline.org/ to edit JSON online.

5. **Review and Double-Check**: Before submitting your JSON file, review it to make sure all the information is correct. This will help us maintain the quality of data in Plan Sync.

6. **Send Us Your JSON File**: Once you've completed the JSON template, send it as an attachment to [connect.plansync@gmail.com](mailto:connect.plansync@gmail.com). Please include your name and contact information in the email so that we can credit you for your contribution.

7. **Verification**: Our team will review the JSON file you submitted for accuracy and completeness. If any corrections are needed, we will communicate with you to make the necessary adjustments.

8. **Incorporate Your Contribution**: Once your JSON file is approved, we will incorporate it into Plan Sync, ensuring that the entire community benefits from your contribution.

## JSON Template
Copy and modify this template for your contribution
<details>
  <summary>Normal Class Template</summary>

```
{
    "meta": {
      "section": "b17",  //replace with your section here
      "type": "norm-class",  // default value, need not to change
      "revision": "Revision 1.0",  // default value, need not to change
      "effective-date": "Aug 31, 2023",
      "contributor": "Legendary Contributor",  //replace with your name here
      "isTimetableUpdating": false,  // default value, need not to change
      
      // add day-wise classroom here
      "room": {
        "monday": 306,
        "tuesday": 306,
        "wednesday": 307,
        "thursday": 303,
        "friday": 304
      }
    },
    "data": {
      "monday": {
        "08:20 - 09:20": "BEE",
        "09:20 - 10:20": "Chem.",
        "10:20 - 11:20": "YHC",
        "11:20 - 12:00": "***",
        "12:00 - 13:00": "Workshop Practical",
        "13:00 - 14:00": "Workshop Practical"
      },
      "tuesday": {
        "08:00 - 09:00": "Electives",
        "09:20 - 10:20": "DE & LA.",
        "10:20 - 11:20": "B.Etc",
        "11:20 - 12:00": "***",
        "12:00 - 13:00": "Engg. Lab",
        "13:00 - 14:00": "Engg. Lab"
      },
      "wednesday": {
        "08:20 - 09:20": "***",
        "09:20 - 10:20": "Eng.",
        "10:20 - 11:20": "DE & LA",
        "11:20 - 12:00": "***",
        "12:00 - 13:00": "Chem. Lab",
        "13:00 - 14:00": "Chem. Lab"
      },
      "thursday": {
        "08:00 - 09:00": "Electives",
        "09:20 - 10:20": "Eng.",
        "10:20 - 11:20": "B.Etc",
        "11:20 - 12:20": "DE & LA",
        "12:20 - 13:20": "Chem",
        "13:20 - 14:20": "***"
      },
      "friday": {
        "08:20 - 09:20": "BEE",
        "09:20 - 10:20": "Comm. Lab",
        "10:20 - 11:20": "Comm. Lab",
        "11:20 - 12:20": "Chem",
        "12:20 - 13:20": "DE & LA",
        "13:20 - 14:20": "***"
      }
    }
  }
```
  
</details>

<details>
  <summary>Electives Template</summary>

```
{
  "meta": {
    "type": "electives",
    "revision": "Revision 1.0",
    "effective-date": "Aug 31, 2023",
    "name": "Electives Configuration for B14 - B23",
          "contributor": "Legendary Contributor",  //replace with your name here
    "isTimetableUpdating": false
  },
  "data": {
    "monday": {
      "***": "***"
    },
    "tuesday": {
      "CIE6": "Room 304",
      "CIE7": "Room 305",
      "CIE8": "Room 301",
      "CIE9": "Room 306",
      "CIE10": "Room 307",
      "SST3": "Room 401",
      "SOE5": "Room 302",
      "SOE6": "Room 402",
      "SOE7": "Room 404",
      "SOE8": "Room 303"
    },
    "wednesday": {
      "***": "***"
    },
    "thursday": {
      "CIE6": "Room 404",
      "CIE7": "Room 302",
      "CIE8": "Room 306",
      "CIE9": "Room 303",
      "CIE10": "Room 304",
      "SST3": "Room 307",
      "SOE5": "Room 401",
      "SOE6": "Room 305",
      "SOE7": "Room 402",
      "SOE8": "Room 403"
    },
    "friday": {
      "***": "***"
    }
  }
}
```
  
</details>

## Guidelines for submission

- Please use the provided JSON template to input your class schedule details.
- Ensure that you provide accurate and up-to-date information.
- Include all relevant information for each class, such as the course name, professor, room number, and timing.
- Create a new Github Issue (If doesn't exist) and attach json there, or
- Use below mentioned mail template to send over your class details.

<details>
  <summary><h3>Send via mail</h3></summary>
Use this template to send us your work, all the details you share will be kept confedential and will be only used for one-to-one communication.


  ```
Subject: [Your Name] - Plan Sync Class Schedule Contribution

Dear Plan Sync Team,

I hope this email finds you well. I am excited to contribute my class schedule details to Plan Sync to help fellow students stay organized. Please find below the required information:

Name: [Your Full Name]
Email: [Your Email Address]
Contact Number: [Your Phone Number]
Section: [Your section]
Branch: [Your branch]
Notes or Comments (if any): [Any additional information or comments you'd like to include]

Feel free to reach out to me if you need any further information or have questions about my contribution.

Attach valid JSON file

Best regards,
[Your Full Name]
[Your Phone Number]
[Today's Date]
```
  
</details>

Thank you for contributing to Plan Sync and helping to create a valuable resource for college students. Your efforts are greatly appreciated!

If you have any questions or need assistance with the contribution process, please don't hesitate to reach out to us at [connect.plansync@gmail.com](mailto:connect.plansync@gmail.com).

Happy scheduling!
