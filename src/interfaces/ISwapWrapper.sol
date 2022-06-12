// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

interface ISwapWrapper {
    function setFee(uint fee) external;
    function setRouter(address router) external;
    function swap(address swapIn, address swapOut, uint amount) external returns (uint);
}