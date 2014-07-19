package main

import (
	"encoding/csv"
	"fmt"
	"io/ioutil"
	"os"
	"net/http"
	"net/http/cookiejar"
//	"runtime"
	"strconv"
//	"strings"
	"sync"
	"time"
	"github.com/moovweb/gokogiri"
)

const base_url = "https://www.goodreads.com"
const rss_xpath = "/html/body/div[1]/div[2]/div[1]/div[1]/div[2]/a"
const quotes_xpath = "//ul[@id='sortable_items']/li"

const goroutine_delay = 35

const retries = 7
const base_sleep = 250*time.Millisecond
const sleep_increment = 250*time.Millisecond
const group_size = 1000

func process(user_id string, rss *csv.Writer) {

	cookieJar, _ := cookiejar.New(nil)

	client := &http.Client{
		Jar: cookieJar,
	}

	user_url := base_url+"/quotes/list/"+user_id

	//fmt.Println(user_url)

	req, err := http.NewRequest("GET", user_url, nil)

	req.Header.Set("User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/34.0.1847.116 Chrome/34.0.1847.116 Safari/537.")
	var body []byte

	current_sleep := base_sleep

	i := 0
	for i < retries {
		
		resp, err := client.Do(req)
		if err != nil {
			fmt.Println(err)
			time.Sleep(current_sleep)
			i++
			current_sleep += sleep_increment
			continue
			//log.Fatalln(err)
		} else {
			defer resp.Body.Close()
			body, err = ioutil.ReadAll(resp.Body)
			if (err != nil) {
				fmt.Println(err)
				time.Sleep(current_sleep)
				i++
				current_sleep += sleep_increment
				continue
			} else {
				break
			}
		}
		return
	}

	doc, err := gokogiri.ParseHtml(body)
	if err != nil {
		fmt.Println(err)
	}
	defer doc.Free()

	qnodes, err := doc.Search(quotes_xpath)
	if err != nil {
		fmt.Println(err)
	}

	//fmt.Println(qnodes)
	//fmt.Println(len(qnodes))

	var q string = strconv.Itoa(len(qnodes))

	if (q=="0") {
		var record []string
		record = append(record, user_id, q, "")
		rss.Write(record)
		return
	}

	nodes, err := doc.Search(rss_xpath)
	if err != nil {
		fmt.Println(err)
	}

	for n := range nodes {
		var record []string
		record = append(record, user_id, q)
		record = append(record, base_url+nodes[n].Attribute("href").Value())
		rss.Write(record)
		}
		
}

func main() {

	//runtime.GOMAXPROCS(4)

	for group := 0;  group<=10; group++ {

		var wg sync.WaitGroup

		file_name := "rss_go_"+strconv.Itoa(group)+".csv"
		f, err := os.Create(file_name)
		if err != nil {
			fmt.Println(err)
		}
	
		rss := csv.NewWriter(f)

		for user_id := group*group_size+1;  user_id<=(group+1)*group_size; user_id++ {

			fmt.Println(user_id)

			wg.Add(1)

			time.Sleep(time.Millisecond*goroutine_delay)
		
			go func() {
				defer wg.Done()
				process(strconv.Itoa(user_id),rss)
			}()

		}
		wg.Wait()
		rss.Flush()

		f.Close()

		time.Sleep(time.Millisecond*1000*30*3)
	}

}
