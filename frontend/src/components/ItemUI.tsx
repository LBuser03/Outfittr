import React, { useState } from 'react';
import { buildPath } from './Path';
import { retrieveToken, storeToken } from '../../../tokenStorage';

function ItemUI() {
    const [message, setMessage] = useState('');
    const [searchResults, setResults] = useState('');
    const [itemList, setItemList] = useState('');
    const [search, setSearchValue] = React.useState('');
    const [item, setItemNameValue] = React.useState('');
    
    // 1. New state for the image file
    const [file, setFile] = useState<File | null>(null);

    var _ud = localStorage.getItem('user_data');
    var ud = JSON.parse(String(_ud));
    var userId = ud.id;

    async function addItem(e: any): Promise<void> {
        e.preventDefault();

        if (!file) {
            setMessage("Please select an image first.");
            return;
        }

        // 2. Use FormData instead of a JSON object
        const formData = new FormData();
        formData.append('image', file);      // The binary image file
        formData.append('userId', userId);    // Text fields
        formData.append('name', item);        // Matches 'name' in our updated api.js
        formData.append('jwtToken', retrieveToken() || '');

        try {
            // 3. Fetch without 'Content-Type' header (Browser adds it for FormData)
            const response = await fetch(buildPath('api/additem'), {
                method: 'POST',
                body: formData 
            });

            let txt = await response.text();
            let res = JSON.parse(txt);

            if (res.error && res.error.length > 0) {
                setMessage("API Error:" + res.error);
            }
            else {
                setMessage('Item has been added');
                storeToken(res.jwtToken);
            }
        }
        catch (error: any) {
            setMessage(error.toString());
        }
    };

    // Keep your searchItem function as is for now, 
    // but eventually we'll change it to handle image URLs!
    async function searchItem(e: any): Promise<void> {
        e.preventDefault();
        var obj = { userId: userId, search: search, jwtToken: retrieveToken() };
        var js = JSON.stringify(obj);
        try {
            const response = await fetch(buildPath('api/searchitems'),
                { method: 'POST', body: js, headers: { 'Content-Type': 'application/json' } });
            let txt = await response.text();
            let res = JSON.parse(txt);
            let _results = res.results;
            let resultText = '';
            for (let i = 0; i < _results.length; i++) {
                resultText += _results[i];
                if (i < _results.length - 1) {
                    resultText += ', ';
                }
            }
            setResults('Item(s) have been retrieved');
            storeToken(res.jwtToken);
            setItemList(resultText);
        }
        catch (error: any) {
            alert(error.toString());
            setResults(error.toString());
        }
    };

    function handleSearchTextChange(e: any): void {
        setSearchValue(e.target.value);
    }

    function handleItemTextChange(e: any): void {
        setItemNameValue(e.target.value);
    }

    // 4. Handle file selection
    function handleFileChange(e: React.ChangeEvent<HTMLInputElement>): void {
        if (e.target.files) {
            setFile(e.target.files[0]);
        }
    }

    return (
        <div id="itemUIDiv">
            <br />
            Search: <input type="text" id="searchText" placeholder="Item To Search For"
                onChange={handleSearchTextChange} />
            <button type="button" id="searchItemButton" className="buttons"
                onClick={searchItem}> Search Item</button><br />
            <span id="itemSearchResult">{searchResults}</span>
            <div id="itemList">{itemList}</div><br /><br />

            <h3>ADD NEW ITEM</h3>
            Name: <input type="text" id="itemText" placeholder="Item Name"
                onChange={handleItemTextChange} /><br />
            
            {/* 5. The File Input */}
            Photo: <input type="file" id="itemFile" accept="image/*" 
                onChange={handleFileChange} /><br />

            <button type="button" id="addItemButton" className="buttons"
                onClick={addItem}> Add Item </button><br />
            <span id="itemAddResult">{message}</span>
        </div>
    );
}

export default ItemUI;