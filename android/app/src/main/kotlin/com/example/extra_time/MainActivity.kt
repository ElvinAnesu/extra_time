package com.example.extra_time

import android.os.Bundle
import android.widget.Toast
import com.sdksuite.omnidriver.OmniConnection
import com.sdksuite.omnidriver.OmniDriver
import com.sdksuite.omnidriver.aidl.printer.ASCScale
import com.sdksuite.omnidriver.aidl.printer.ASCSize
import com.sdksuite.omnidriver.aidl.printer.Align
import com.sdksuite.omnidriver.aidl.printer.ECLevel
import com.sdksuite.omnidriver.aidl.printer.HZScale
import com.sdksuite.omnidriver.aidl.printer.HZSize
import com.sdksuite.omnidriver.api.KeyConst
import com.sdksuite.omnidriver.api.OnPrintListener
import com.sdksuite.omnidriver.api.Printer
import com.sdksuite.omnidriver.api.PrinterException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private val channelName = "printerChannel"
    private var retryCount: Int = 0
    var mOmniDriver: OmniDriver = OmniDriver.me(this)


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val method = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        method.setMethodCallHandler { call, result ->
            if (call.method == "printVoucher"){
                Toast.makeText(this, "block", Toast.LENGTH_SHORT).show()
                var isInitSuccess: Boolean = false

                mOmniDriver.init(object : OmniConnection {
                    override fun onConnected() {
                        isInitSuccess = true
                    }
                    override fun onDisconnected(error: Int) {
                        isInitSuccess = false
                        if (error == OmniDriver.ERROR_BIND_FAIL) {
                            return
                        }
                    }
                })

                if(isInitSuccess){
                    val printer: Printer = mOmniDriver.getPrinter(Bundle())

                    try {
                        printer.openDevice(0)
                        Toast.makeText(this, "Printing", Toast.LENGTH_SHORT).show()
                        val status = printer.getStatus()
                        if (status != 0) {
                            Toast.makeText(this, "Printer error status $status", Toast.LENGTH_SHORT).show()
                        }
                        printer.setGray(8)
                        //Print multiple lines and automatically wrap (0x4801), if there are more than one line, the excess text will be removed and only one line will be printed (0x4800).
                        printer.setFormat(0x0800, 0x4801)
                        //Print the digit 0 without a slash (0x01), by default, the slash is present (0x00).
                        printer.setFormat(0x4000, 0x01)

                        printer.setFormat(Bundle().apply {
                            putInt(KeyConst.PRINTER_ASC_SIZE, ASCSize.DOT24x12)
                            putInt(KeyConst.PRINTER_ASC_SCALE, ASCScale.SC1x3)
                            putInt(KeyConst.PRINTER_HZ_SIZE, HZSize.DOT24x24)
                            putInt(KeyConst.PRINTER_HZ_SCALE, HZScale.SC1x3)
                        })
                        printer.addText("Title\n", Align.CENTER)

                        printer.setFormat(Bundle().apply {
                            putInt(KeyConst.PRINTER_ASC_SIZE, ASCSize.DOT24x12)
                            putInt(KeyConst.PRINTER_ASC_SCALE, ASCScale.SC1x1)
                            putInt(KeyConst.PRINTER_HZ_SIZE, HZSize.DOT24x24)
                            putInt(KeyConst.PRINTER_HZ_SCALE, HZScale.SC1x1)
                        })
                        printer.addText("My Zesa token\n", Align.LEFT)

                        printer.setFormat(Bundle().apply {
                            putInt(KeyConst.PRINTER_ASC_SIZE, ASCSize.DOT24x8)
                            putInt(KeyConst.PRINTER_ASC_SCALE, ASCScale.SC2x1)
                        })
                        printer.addText("printer underline:\u0007Extratime\u0008\n", Align.LEFT)

                        printer.setFormat(Bundle().apply {
                            putInt(KeyConst.PRINTER_ASC_SIZE, ASCSize.DOT16x8)
                            putInt(KeyConst.PRINTER_ASC_SCALE, ASCScale.SC1x1)
                            putInt(KeyConst.PRINTER_HZ_SIZE, HZSize.DOT16x16)
                            putInt(KeyConst.PRINTER_HZ_SCALE, HZScale.SC1x1)
                        })
                        printer.startPrint(object : OnPrintListener {
                            override fun onSuccess() {
                                Toast.makeText(this@MainActivity, "Done", Toast.LENGTH_SHORT).show()
                            }

                            override fun onFail(error: Int) {
                                Toast.makeText(this@MainActivity, "printer result--->error=$error", Toast.LENGTH_SHORT).show()

                            }
                        })
                    } catch (e: PrinterException) {
                        Toast.makeText(this@MainActivity, "printer error--->${e.message}", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }

}

