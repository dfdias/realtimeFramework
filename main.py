import uhd
from dds_gen import dds_gen
import threading
import time
from multiprocessing import Process
from scipy.io import savemat
import numpy as np
import queue
from plotter import plotter

CLOCK_TIMEOUT = 1000  # 1000mS timeout for external clock locking
INIT_DELAY = 0.05  # 50mS initial delay before transmit


def main():
    '''Estou a seguir quase à linha o código que fiz em C++'''

    # RF Frontend Setup
    device_args = "serial=31167B6"
    subdevTX = "A:A"
    subdevRX = "A:A"
    ant_tx = "TX/RX"
    ant_rx = "RX2"
    rx_gain = 70
    tx_gain = 70
    ref = "internal"
    # sampRateSig = 400e3;
    Fs = 400e3
    N = 2040
    F0 = 5.9e9
    periodsamps = round(Fs / 10e3)
    gen = dds_gen(periodsamps, Fs, 1, 10e3, True)

    usrp = uhd.usrp.MultiUSRP(device_args)
    usrp.set_rx_subdev_spec(uhd.usrp.SubdevSpec(subdevRX))
    usrp.set_tx_subdev_spec(uhd.usrp.SubdevSpec(subdevTX))
    print(usrp.get_pp_string())
    usrp.set_clock_source(ref)
    usrp.set_rx_antenna(ant_rx)
    usrp.set_tx_antenna(ant_tx)
    usrp.set_rx_bandwidth(Fs)
    usrp.set_tx_bandwidth(Fs)
    usrp.set_rx_rate(Fs)
    usrp.set_tx_rate(Fs)
    usrp.set_rx_gain(rx_gain)
    usrp.set_tx_gain(tx_gain)

    tune = uhd.types.TuneRequest(target_freq=F0)  # this one was an hard sob

    usrp.set_tx_freq(tune_request=tune, chan=0)
    usrp.set_rx_freq(tune_request=tune, chan=0)

    usrp.set_time_now(uhd.types.TimeSpec(0.0))

    print("USRP CONFIG REPORT")
    print(usrp.get_pp_string())
    print("USRP RX ANTENNA =>", usrp.get_rx_antenna())
    print("USRP TX ANTENNA =>", usrp.get_tx_antenna())
    print("USRP RX RATE =>", usrp.get_rx_rate())
    print("USRP TX RATE =>", usrp.get_tx_rate())
    print("USRP RX GAIN =>", usrp.get_rx_gain(), "dB")
    print("USRP TX GAIN =>", usrp.get_tx_gain(), "dB")
    print("USRP TX freq =>", usrp.get_tx_freq() / 1e9, "GHz")
    print("USRP RX freq =>", usrp.get_rx_freq() / 1e9, "GHz")

    b = True
    #tx(usrp,Fs,1e6)
    # while b is True:
    #     a = usrp.recv_num_samps(int(10e6),5e9,5e6)
    #     b = True
    q = queue.Queue()
    plots = plotter(Fs)

    st_args = uhd.usrp.StreamArgs("fc32", "sc16")
    st_args.channels = (0,)
    metadata = uhd.types.RXMetadata()
    streamer = usrp.get_rx_stream(st_args)
    channels = st_args.channels
    buffer_samps = streamer.get_max_num_samps()
    recv_buffer = np.zeros((1,2040), dtype=np.complex64)
    num_samps = 1000 * buffer_samps
    result = np.empty((len(channels), num_samps), dtype=np.complex64)
    recv_samps = 0
    stream_cmd = uhd.types.StreamCMD(uhd.types.StreamMode.start_cont)
    stream_cmd.stream_now = True
    streamer.issue_stream_cmd(stream_cmd)
    samps = np.array([], dtype=np.complex64)
    x = threading.Thread(target=tx, args=(usrp, Fs, 10e3,),daemon=True)
    x.start()

    idx = 1
    b = True
    while b is True:
        idx += 1
        #print(idx)
        samps = streamer.recv(recv_buffer, metadata)
        a = recv_buffer.flatten()
        t1 = time.time()
        q.put(a)
        t1elapsed = time.time()-t1
        print(t1elapsed)
        recv_buffer = np.zeros((1, 2040), dtype=np.complex64)
        if idx > 1e4:
            b = False
            x = np.zeros((1,2040*10000),dtype=np.complex64)
            i = 0
            while q.empty() is False:
                x[0,i*2040:(i+1)*2040] = q.get()
            #x = np.asarray(a)
            b = False

    i = 0
    mdic={"Fs": Fs, "x": x}
    print(mdic)
    savemat("received.mat",mdic)
    print(idx)        # #if metadata.error_code != uhd.types.RXMetadataErrorCode.none:
        #  # print(metadata.strerror())
        # if samps.size > 0:
        #     real_samps = min(num_samps - recv_samps, samps)
        #     result[:, recv_samps:recv_samps + real_samps] = recv_buffer[:, 0:real_samps]
        #     recv_samps += real_samps





def tx(usrp,Fs,Fsine):

    dds = dds_gen(2040,Fs,1,Fsine,True)
    # txworker preparation
    st_args = uhd.usrp.StreamArgs("fc32", "sc16")
    st_args.channels = (0,)
    streamer = usrp.get_tx_stream(st_args)
    metadata = uhd.types.TXMetadata()
    buffer_samps = streamer.get_max_num_samps()
    print(buffer_samps)
    # wave configuration
    waveforms = {
        "sine": lambda n, tone_offset, rate: np.exp(n * 2j * np.pi * tone_offset / rate),
        "square": lambda n, tone_offset, rate: np.sign(waveforms["sine"](n, tone_offset, rate)),
        "const": lambda n, tone_offset, rate: 1 + 1j,
        "ramp": lambda n, tone_offset, rate:
        2 * (n * (tone_offset / rate) - np.floor(float(0.5 + n * (tone_offset / rate))))
    }
    A = 1
    type = "sine"
    waveform_proto = np.array(
        list(map(lambda n: A * waveforms[type](n, Fsine, Fs),
            np.arange(
                int(10 * np.floor(Fs / Fsine)),
                dtype=np.complex64))),
        dtype=np.complex64)
    txdic ={"Fs": Fs, "x": waveform_proto}
    savemat("proto.mat",txdic)
    channels = st_args.channels
    proto_len = waveform_proto.shape[-1]
    if proto_len < buffer_samps:
        waveform_proto = np.tile(waveform_proto,
                                 (1, int(np.ceil(float(buffer_samps) / proto_len))))
        proto_len = waveform_proto.shape[-1]

    if len(waveform_proto.shape) == 1:
        waveform_proto = waveform_proto.reshape(1, waveform_proto.size)
    if waveform_proto.shape[0] < len(channels):
        waveform_proto = np.tile(waveform_proto[0], (len(channels), 1))
    while True:
        streamer.send(waveform_proto, metadata)


if __name__ == "__main__":
    main()
