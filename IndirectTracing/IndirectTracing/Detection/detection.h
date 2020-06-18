#pragma once
#pragma warning(disable : 4996) //_CRT_SECURE_NO_WARNINGS
#include <map>
#include <list> 
#include <string>
#include <vector>

using namespace std;


struct LOCATION
{
	int timestamp;
	map<string, double> scaned_wifi;
};
/*
The data structue to store wifi/ibeacon profile of a location. 
e.g. At the timestamp 1587039132, we scane WIFI "A" with strength of -70 and "B" with strength of - 80 at a location: timestamp = 1587039132; scaned_wifi = {"A":-70, "B":-80}. 

Note that a trajectory consists of a list of locations.
*/



struct duration
{
	int start;
	int end;
	int risk;
};
/* The data structure to store the information of the duration staying in a place. start indicates the start time, end indicates the end time, and risk indicates the risk of the place. */


struct BLE_duration
{
	int timestamp;
	string risk;
};
/* The data structure for BLE detection to store the information of the duration staying in a place. timestamp indicates the contact time, while rssi indicates the signal strength */

/*struct region_profile
{
	vector<string> ap_ids;
	int start;
	int end;
};*/

struct ap_profile
{
	string ssid;
	int max_rssi;
	int min_rssi;
};

struct region_profile
{
	vector<ap_profile> aps;
	int start; // the start time of a confirmed case stay in the infected region;
	int end; // the end time of a confirmed case stay in the infected region;
};
/* Because some confirmed cases may not use our app, we do not have their WIFI/iBeacon data, ***we have to assign staffs to collect these data in confirmed cases' visited places by ourselves***.
   ap_ids is the WIFI/ibeacon scanned in the visited place; 
   start and end are the start time and end time, indicating a confirmed case was at the place from start to end. 

   Note that each place has a region_profile. Since confirmed cases would visited a lot of place, there will be a list of region_profiles.

*/



class detection
{
public:


	/*      **********************************************       For Indirect contact tracing *********************************************    */

	/*      **********************************************  1. Confirmed case's trajectory data is uploaded. *********************************************    */


	tuple<int, int> cal_risk(LOCATION w, vector <LOCATION> trajectory, double near_strength_threshold = 40.0, double medium_strength_threshold = 40.0, double distant_strength_threshold = 40.0);
	/*Given a location, the trajectory of a confirmed case and three thresholds:
	1. return <-1, -1> if the confirmed case has not been to the location;
	2. return <t, r> indicating the case has been to the location at the time t and the location is of risk r:
																											  * 0: safe place;
																											  * 1: distant place;
																										      * 2. medium place;
																											  * 3. near place
	*/


	
	tuple<int, vector<duration>> cal_contact_duration(vector<LOCATION> trajectory_1, vector<LOCATION> trajectory_2, double near_strength_threshold = 40.0, double medium_strength_threshold = 40.0, double distant_strength_threshold = 40.0); // trajectory_1 for a testing user and trajectory for a confirmed case;
	/*Given the trajectory of a user, the trajectory of a confirmed case and some thresholds:
	it returns * the total duration of the indirect contact
			   * and
			   * the time windows with <start-time, end-time, r> indicating a user was in the infected location from start-time to end_time and the risk is r:
			   * 0: safe place;
			   * 1: distant place;
			   * 2. medium place;
			   * 3. near place
	*/





	/*      **********************************************  2. Confirmed case's trajectory data is not uploaded, site survey data of infected region is used. *********************************************    */


	
	duration cal_risk_region(LOCATION w, vector<region_profile> regions, double near_overlap_thres = 0.5, double medium_overlap_thres = 0.4, double distant_overlap_thres = 0.2);
	/*  Given a location and the wifi/ibeacon profile of a list of infected regions, it returns <start-time, end-time, risk>, indicating a confirmed case staysout
	there from the start-time to endtime 
		and risk of the place is:
		0: safe place;
		1: distant place;
		2. medium place;
		3. near place

	*/

	

	tuple<int, vector<duration>> cal_risk_region_duration(vector<LOCATION> trajectory, vector<region_profile> regions, double near_overlap_thres = 0.5, double medium_overlap_thres = 0.4, double distant_overlap_thres = 0.2);
	/* Given a user's trajectory and wifi/ibeacon profile of a list of infected regions,
	   it returns * the total duration of the indirect contact
				  * the the time windows with <start-time, end-time, r> indicating a user was in the infected location from start-time to end_time and the risk is r:
				  * 0: safe place;
				  * 1: distant place;
				  * 2. medium place;
				  * 3. near place
	*/






	/*      **********************************************       For Direct contact tracing *********************************************    */

	
	tuple<int, vector<duration>> direct_contact_detection(vector<LOCATION> trajectory_1, vector<LOCATION> trajectory_2, double near_strength_threshold = 50.0, double medium_strength_threshold = 60.0, double distant_strength_threshold = 70.0);
	/* Given a user's trajectory, a confirmed case's trajectory and some thresholds,
	   it returns * the total duration of the direct contact
				  * the the time windows with <start-time, end-time, r> indicating a user stayed with the confirmed case from start-time to end_time and the risk is r:
				  * 0: safe place;
				  * 1: distant place;
				  * 2. medium place;
				  * 3. near place



	*/

	tuple<int, vector<duration>> direct_contact_detect_region(vector<LOCATION> trajectory, vector<region_profile> regions, double near_overlap_thres = 0.5, double medium_overlap_thres = 0.4, double distant_overlap_thres = 0.2);
	/* Given a user's trajectory, a list of region profiles and some thresholds,
	   it returns * the total duration of the direct contact
				  * the the time windows with <start-time, end-time, r> indicating a user stayed with the confirmed case from start-time to end_time and the risk is r:
				  * 0: safe place;
				  * 1: distant place;
				  * 2. medium place;
				  * 3. near place

				 

	*/

	

	/*      **********************************************       Fusing the WIFI direct detection and BLE direct detection  *********************************************    */

	tuple<int, vector<duration>> fusion_WIFI_BLE(vector<duration> wifi_detection, vector<BLE_duration> ble_detection);
	/* Given the WIFI direct detection result and the BLE direct detection result, it will return the total contact duration of a user and the contact records.
	1. WIFI detection result is a list of durations, each of which contains a start-time (int), end_time (int), and the risk (int)
	2. BLE detection result is a list of durations, each of which contains a timestamp (int) and the risk (string).

	struct duration
	{
	int start;
	int end;
	int risk;
	};
	
	struct BLE_duration
	{
		int timestamp;
		string risk;
	};

	*/


};

