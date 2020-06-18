#include "detection.h"
#include <map>
#include <string>
#include <ctime>
#include <iostream>
#include <vector>
using namespace std;
using namespace std;




double cal_sim(LOCATION w1, LOCATION w2)
{
	double dis = 0.0;
	int count = 0;
	map<string, double>::iterator iter;
	map<string, double>::iterator iter2;

	for (iter = w1.scaned_wifi.begin(); iter != w1.scaned_wifi.end(); iter++)
	{
		iter2 = w2.scaned_wifi.find(iter->first);
		if (iter2 != w2.scaned_wifi.end())
		{
			dis += abs(iter2->second - iter->second);
			count += 1;
		}
		else
		{
			dis += 100;
			count += 1;
		}
	}
	for (iter = w2.scaned_wifi.begin(); iter != w2.scaned_wifi.end(); iter++)
	{
		iter2 = w1.scaned_wifi.find(iter->first);
		if (iter2 == w1.scaned_wifi.end())
		{
			dis += 100;
			count += 1;
		}
	}

	return dis / count;
}



vector< duration > generate_contact_time_sequence(vector<int> contact_time, vector<int> contact_risk)
{

	vector <duration> start_end;
	if (contact_time.size() == 0)
	{
		return start_end;
	}

	int start_time = contact_time[0];
	int end_time = contact_time[0];
	int max_risk = contact_risk[0];
	for (int i = 1; i < contact_time.size();i++)
	{

		if (contact_time[i] - end_time <= 3 * 60 + 10)
		{
			end_time = contact_time[i];
			if (contact_risk[i] > max_risk)
			{
				max_risk = contact_risk[i];
			}
		}
		else
		{
			if (end_time - start_time >= 5 * 60)
			{
				duration d;
				d.start = start_time;
				d.end = end_time;
				d.risk = max_risk;
				start_end.push_back(d);
			}

			start_time = contact_time[i];
			end_time = contact_time[i];
			max_risk = contact_risk[i];
		}

	}
	if (end_time - start_time >= 5 * 60)
	{
		duration d;
		d.start = start_time;
		d.end = end_time;
		d.risk = max_risk;
		start_end.push_back(d);
	}

	return start_end;
}



tuple<int, int> detection::cal_risk(LOCATION w, vector <LOCATION> trajectory, double near_strength_threshold, double medium_strength_threshold, double distant_strength_threshold)
{
	//list <LOCATION>::iterator iter;
	double min_dis = 1000;
	double t = 0;
	int risk = 0;
	for (LOCATION w2 : trajectory)
	{
		double dis = cal_sim(w, w2);
		if (dis < min_dis)
		{
			min_dis = dis;
			t = w2.timestamp;
		}
		if (min_dis <= near_strength_threshold)
		{
			break;
		}
	}
	if (min_dis <= near_strength_threshold)
	{
		risk = 3;
	}
	else if (min_dis <= medium_strength_threshold)
	{
		risk = 2;
	}
	else if (min_dis <= distant_strength_threshold)
	{
		risk = 1;
	}

	if (risk != 0)
	{
		tuple<int, int> result(t, risk);
		return result;
	}
	else
	{
		tuple<int, int> result(-1, -1);
		return result;
	}


	/*if (min_dis < strength_threshold)
	{
		time_t now = time(0);
		tm* ltm = localtime(&now);
		int difference = int(now) - t - (int(ltm->tm_hour) - 1) * 3600 - (int(ltm->tm_min) - 1) * 6 - int(ltm->tm_sec);
		int day = ceil(difference * 1.0 / (24 * 3600));
		return day;

	}
	else
	{
		return -1;
	}*/


	/*if (min_dis <= 50)
	{
		return [2, day]; // very dangerous
	}

	else if(min_dis < 60)
	{
		return [1, day]; // dangerous
	}

	else
	{
		return []; //safe
	}*/

}



tuple<int, vector<duration>> detection::cal_contact_duration(vector<LOCATION> trajectory_1, vector<LOCATION> trajectory_2, double near_strength_threshold, double medium_strength_threshold, double distant_strength_threshold)
{

	vector <int> contact_time;
	vector <int> contact_risk;
	double dis = 0;
	for (LOCATION w1 : trajectory_1)
	{
		int risk = 0;
		int min_dis = 1000;
		for (LOCATION w2 : trajectory_2)
		{

			dis = cal_sim(w1, w2);

			if (dis < min_dis)
			{
				min_dis = dis;
			}
			if (min_dis < near_strength_threshold)
			{
				break;
			}
		}
		if (min_dis < near_strength_threshold)
		{
			risk = 3;
		}
		else if (min_dis < medium_strength_threshold)
		{
			risk = 2;
		}
		else if (min_dis < distant_strength_threshold)
		{
			risk = 1;
		}

		if (risk != 0)
		{
			contact_time.push_back(w1.timestamp);
			contact_risk.push_back(risk);
		}
	}

	vector<duration> start_end = generate_contact_time_sequence(contact_time, contact_risk);
	int duration_time = 0;
	for (duration d : start_end)
	{
		if (d.start == d.end)
		{
			duration_time += 60;
		}
		else
		{
			duration_time = duration_time + (d.end - d.start);
		}
	}
	tuple<int, vector<duration>> result(duration_time, start_end);

	return result;
}





int cal_risk_region_simple(LOCATION w, vector<ap_profile> aps, double near_overlap_thres, double medium_overlap_thres, double distant_overlap_thres)
{

	map<string, double>::iterator iter;
	double overlap = 0;
	double total = 0;
	for (iter = w.scaned_wifi.begin(); iter != w.scaned_wifi.end(); iter++)
	{
		total++;
		string bssid = iter->first;
		int rssi = iter->second;

		for (ap_profile ap : aps)
		{

			if (ap.ssid == bssid && rssi <= ap.max_rssi && rssi >= ap.min_rssi)
			{

				overlap += 1;
				break;
			}
		}
	}
	double result = overlap / total;

	if (result >= near_overlap_thres)
	{
		return 3;
	}
	else if (result >= medium_overlap_thres)
	{
		return 2;
	}
	else if (result >= distant_overlap_thres)
	{
		return 1;
	}
	else
	{
		return 0;
	}


}


duration detection::cal_risk_region(LOCATION w, vector<region_profile> regions, double near_overlap_thres, double medium_overlap_thres, double distant_overlap_thres)
{
	int max_risk = 0;
	int start = 0;
	int end = 0;
	for (region_profile region : regions)
	{
		vector<ap_profile> aps = region.aps;
		int risk = cal_risk_region_simple(w, aps, near_overlap_thres, medium_overlap_thres, distant_overlap_thres);

		if (risk > max_risk)
		{
			max_risk = risk;
			start = region.start;
			end = region.end;
		}
		if (max_risk > 2)
		{
			break;
		}
	}
	duration d;
	d.risk = max_risk;
	d.start = start;
	d.end = end;

	return d;
}








tuple<int, vector<duration>> detection::cal_risk_region_duration(vector<LOCATION> trajectory, vector<region_profile> regions, double near_overlap_thres, double medium_overlap_thres, double distant_overlap_thres)
{


	vector <int> contact_time;
	vector <int> contact_risk;
	for (LOCATION w : trajectory)
	{
		duration d = cal_risk_region(w, regions, near_overlap_thres, medium_overlap_thres, distant_overlap_thres);
		if (d.risk > 0)
		{
			contact_time.push_back(w.timestamp);
			contact_risk.push_back(d.risk);
		}
	}

	vector<duration> start_end = generate_contact_time_sequence(contact_time, contact_risk);
	int duration_time = 0.0;
	for (duration d : start_end)
	{
		if (d.start == d.end)
		{
			duration_time += 60;
		}
		else
		{
			duration_time = duration_time + d.end - d.start;
		}
	}
	tuple<int, vector<duration>> result(duration_time, start_end);
	return result;


}







tuple<int, vector<duration>> detection::direct_contact_detection(vector<LOCATION> trajectory_1, vector<LOCATION> trajectory_2, double near_strength_threshold, double medium_strength_threshold, double distant_strength_threshold)
{
	vector<int> contact_time;
	vector<int> contact_risk;
	int total_duration = 0;
	for (LOCATION location_1 : trajectory_1)
	{
		int t_1 = location_1.timestamp;
		map<string, double> wifi_1 = location_1.scaned_wifi;
		double min_dis = 1000;
		int risk = 0;

		for (LOCATION location_2 : trajectory_2)
		{
			int t_2 = location_2.timestamp;
			if (t_1 - t_2 > 60)
			{
				continue;
			}
			else if (t_2 - t_1 > 60)
			{
				break;
			}
			map<string, double> wifi_2 = location_2.scaned_wifi;
			double dis = cal_sim(location_1, location_2);
			if (dis < min_dis)
			{
				min_dis = dis;
			}

			if (min_dis <= near_strength_threshold)
			{
				break;
			}

		}

		if (min_dis <= near_strength_threshold)
		{
			risk = 3;
		}
		else if (min_dis <= medium_strength_threshold)
		{
			risk = 2;
		}
		else if (min_dis <= distant_strength_threshold)
		{

			risk = 1;
		}

		if (risk > 0)
		{
			contact_time.push_back(t_1);
			contact_risk.push_back(risk);
		}
	}

	vector<duration> start_end = generate_contact_time_sequence(contact_time, contact_risk);
	for (duration d : start_end)
	{
		if (d.start == d.end)
		{
			total_duration += 60;
		}
		else
		{
			total_duration += d.end - d.start;
		}
	}
	tuple<int, vector<duration>> result(total_duration, start_end);
	return result;

}






tuple<int, vector<duration>> detection::direct_contact_detect_region(vector<LOCATION> trajectory, vector<region_profile> regions, double near_overlap_thres, double medium_overlap_thres, double distant_overlap_thres)
{
	vector<int> contact_time;
	vector<int> contact_risk;
	int total_duration = 0;
	for (LOCATION w : trajectory)
	{
		int t = w.timestamp;

		int max_risk = 0;
		for (region_profile region : regions)
		{
			int start = region.start;
			int end = region.end;
			if (t < start - 300 || t > end + 300)
			{
				continue;
			}
			else
			{
				int risk = cal_risk_region_simple(w, region.aps, near_overlap_thres, medium_overlap_thres, distant_overlap_thres);
				if (risk > max_risk)
				{
					max_risk = risk;
				}
				if (max_risk > 2)
				{
					break;
				}
			}
		}
		if (max_risk != 0)
		{
			contact_time.push_back(t);
			contact_risk.push_back(max_risk);
		}
	}

	vector<duration> start_end = generate_contact_time_sequence(contact_time, contact_risk);
	for (duration d : start_end)
	{
		if (d.start == d.end)
		{
			total_duration += 60;
		}
		else
		{
			total_duration = total_duration + d.end - d.start;
		}
	}
	tuple<int, vector<duration>> result(total_duration, start_end);
	return result;

}

tuple<int, vector<duration>> detection::fusion_WIFI_BLE(vector<duration> wifi_detection, vector<BLE_duration> ble_detection)
{
	vector<duration> contact_result;
	for (BLE_duration ble : ble_detection)
	{
		int t = ble.timestamp;
		string risk = ble.risk;
		int flag = 0;
		for (duration wifi : wifi_detection)
		{
			int start = wifi.start;
			int end = wifi.end;
			int risk = wifi.risk;
			if (t >= start && t <= end)
			{
				flag = 1;
				break;
			}
		}
		if (flag == 0)
		{
			duration d;
			d.start = t;
			d.end = t;

			if (risk == "near") d.risk = 3;
			else if (risk == "medium") d.risk = 2;
			else if (risk == "distant") d.risk = 1;
			else if (risk == "unknown") d.risk = -1;
			contact_result.push_back(d);
		}
	}

	for (duration wifi : wifi_detection)
	{
		contact_result.push_back(wifi);
	}
	int total_duration = 0;
	for (duration d : contact_result)
	{
		if (d.start == d.end)
		{
			total_duration += 60;
		}
		else
		{
			total_duration = total_duration + d.end - d.start;
		}
	}
	tuple<int, vector<duration>> result(total_duration, contact_result);

	return result;
}


